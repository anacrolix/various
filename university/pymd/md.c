#include <Python.h>
#include <stdbool.h>

typedef struct {double x, y, z;} vector;
typedef struct {vector pos, vel;} molecule;

/// takes a Python list of spheres with position and velocity vectors and returns the classical kinetic energy of the system
static PyObject *
total_ke(PyObject *self, PyObject *args)
{
	/*
	def total_ke(molecules):
		ke = 0.0
		for mol in molecules:
			ke += abs(mol.vel) ** 2
		return ke / 2
	*/
	double ke = 0.0;
	PyObject *mol_list;
	if (!PyArg_ParseTuple(args, "O", &mol_list)) return NULL;
	if (!PyList_Check(mol_list)) return NULL;
	long size = PyList_Size(mol_list);
	for (long i = 0; i < size; i++) {
		PyObject *mol, *vel, *abs;
		if (!(mol = PyList_GetItem(mol_list, i))) return NULL;
		if (!(vel = PyObject_GetAttrString(mol, "vel"))) return NULL;	
		if (!(abs = PyNumber_Absolute(vel))) return NULL;
		double tke = PyFloat_AsDouble(abs);
		ke += pow(tke, 2);
		Py_DECREF(vel);
		Py_DECREF(abs);
	}
	return Py_BuildValue("d", ke / 2);
}

/// takes a Python list of spheres with position and velocity vectors and returns the Lennard-Jones potential of the system
static PyObject *
total_pe(PyObject *self, PyObject *args)
{
	/*
	def total_pe():
		pe = 0.0
		for m1 in range(len(molecules)):
			mol1 = molecules[m1]
			for m2 in range(m1 + 1, len(molecules)):
				mol2 = molecules[m2]
				r12 = abs(mol1.pos - mol2.pos)
				assert abs(mol2.pos - mol1.pos) == r12
				pe += r12 ** -6 * (r12 ** -6 - 2)
		return pe 
	*/
	double pe = 0.0;
	PyObject *mol_list;
	if (!PyArg_ParseTuple(args, "O", &mol_list)) return NULL;
	if (!PyList_Check(mol_list)) return NULL;
	long size = PyList_Size(mol_list);
	for (long m1 = 0; m1 < size; m1++) {
		PyObject *mol1, *mol1pos;
		if (!(mol1 = PyList_GetItem(mol_list, m1))) return NULL;
		if (!(mol1pos = PyObject_GetAttrString(mol1, "pos"))) return NULL;
		for (long m2 = m1 + 1; m2 < size; m2++) {
			PyObject *mol2, *mol2pos, *r12vec, *pysep;
			if (!(mol2 = PyList_GetItem(mol_list, m2))) return NULL;
			if (!(mol2pos = PyObject_GetAttrString(mol2, "pos"))) return NULL;
			if (!(r12vec = PyNumber_Subtract(mol1pos, mol2pos))) return NULL;
			if (!(pysep = PyNumber_Absolute(r12vec))) return NULL;
			double r12 = PyFloat_AsDouble(pysep);
			pe += pow(r12, -6) * (pow(r12, -6) - 2);
			Py_DECREF(mol2pos);
			Py_DECREF(r12vec);
			Py_DECREF(pysep);
		}
		Py_DECREF(mol1pos);
	}	
	return Py_BuildValue("d", pe);
}

/// packs a Python visual.vector into a C vector
static inline bool
get_vector(PyObject *pyvec, vector *cvec)
{
	PyObject *x, *y, *z;
	x = PyObject_GetAttrString(pyvec, "x");
	y = PyObject_GetAttrString(pyvec, "y");
	z = PyObject_GetAttrString(pyvec, "z");
	if (!x || !y || !z) return false;
	cvec->x = PyFloat_AsDouble(x);
	cvec->y = PyFloat_AsDouble(y);
	cvec->z = PyFloat_AsDouble(z);
	Py_DECREF(x);
	Py_DECREF(y);
	Py_DECREF(z);
	return true;
}

/// sets a Python visual.vector from a C vector
static inline bool
set_vector(PyObject *pyvec, vector *cvec)
{
	PyObject *x, *y, *z;
	x = Py_BuildValue("d", cvec->x);
	y = Py_BuildValue("d", cvec->y);
	z = Py_BuildValue("d", cvec->z);
	if (PyObject_SetAttrString(pyvec, "x", x) == -1) return false;
	if (PyObject_SetAttrString(pyvec, "y", y) == -1) return false;
	if (PyObject_SetAttrString(pyvec, "z", z) == -1) return false;
	return true;
}

/// derives the acceleration using the potential on each molecule
static inline bool
get_accels(vector accels[], molecule mols[], long size)
{
	/*
	def get_accels(molecules):
		accels = []
		for mol1 in molecules:
			accel = vector()
			for mol2 in molecules:
				if mol1 == mol2: continue
				r12 = abs(mol1.pos - mol2.pos)
				assert abs(mol2.pos - mol1.pos) == r12
				fcom = (12 * r12 ** -8) * (r12 ** -6 - 1)
				force = fcom * (mol1.pos - mol2.pos)
				accel += force
			accels.append(accel)
		return accels
	*/
	// note the code has deviated from the initial python skeleton above
	for (long v = 0; v < size; v++) {
		accels[v].x = 0;
		accels[v].y = 0;
		accels[v].z = 0;
	}
	for (long a = 0; a < size; a++) {
		vector p1 = mols[a].pos;
		for (long b = a + 1; b < size; b++) {
			vector p2 = mols[b].pos;
			double r12 = sqrt(pow(p1.x - p2.x, 2) 
				+ pow(p1.y - p2.y, 2) 
				+ pow(p1.z - p2.z, 2));
			double fcom = (12 * pow(r12, -8)) * (pow(r12, -6) - 1);
			accels[a].x += fcom * (p1.x - p2.x);
			accels[a].y += fcom * (p1.y - p2.y);
			accels[a].z += fcom * (p1.z - p2.z);
			accels[b].x += fcom * (p2.x - p1.x);
			accels[b].y += fcom * (p2.y - p1.y);
			accels[b].z += fcom * (p2.z - p1.z);
		}
	}
	return true;
}

/// apply the velocity verlet algorithm for a number of time steps before returning the results
static PyObject *
update_mols(PyObject *self, PyObject *args)
{
	/*
	def step_mols(molecules):
		# get a(t)
		accels = get_accels(molecules)
		for a in range(len(accels)):
			molecules[a].accel = accels[a]
		# get r(t+dt)
		for m in range(len(molecules)):
			mol = molecules[m]
			mol.pos += dt * (mol.vel + dt * accels[m] / 2)
		# get v(t+dt)
		acceldts = get_accels(molecules)
		for m in range(len(molecules)):
			molecules[m].vel += dt * (molecules[m].accel + acceldts[m]) / 2

	def update_mols(molecules, steps):
		for step in range(steps):
			step_mols(molecules)
		return steps
	*/
	PyObject *mol_list;
	long max_steps;
	double dt;
	if (!PyArg_ParseTuple(args, "Old", &mol_list, &max_steps, &dt)) 
		return NULL;
	if (!PyList_Check(mol_list)) return NULL;
	//fprintf(stderr, "%f\n", dt);
	// get list size
	long size = PyList_Size(mol_list);
	// retrieve each molecules pos and velocity
	molecule mols[size];
	for (long i = 0; i < size; i++) {
		PyObject *mol;
		if (!(mol = PyList_GetItem(mol_list, i))) return NULL;
		PyObject *pos, *vel;
		if (!(pos = PyObject_GetAttrString(mol, "pos"))) return NULL;
		if (!(vel = PyObject_GetAttrString(mol, "vel"))) return NULL;
		if (!get_vector(pos, &mols[i].pos)) return NULL;
		if (!get_vector(vel, &mols[i].vel)) return NULL;
		Py_DECREF(pos);
		Py_DECREF(vel);
	}
	for (long s = 0; s < max_steps; s++) {
		// get acceleration
		vector accels[size];
		if (!get_accels(accels, mols, size)) return NULL;	
		// update molecule positions	
		for (long i = 0; i < size; i++) {
			//mols[i].pos.x += 
			///mol.pos += dt * (mol.vel + dt * accels[m] / 2)
			mols[i].pos.x += dt * (mols[i].vel.x + dt * accels[i].x / 2);
			mols[i].pos.y += dt * (mols[i].vel.y + dt * accels[i].y / 2);
			mols[i].pos.z += dt * (mols[i].vel.z + dt * accels[i].z / 2);		
		}
		// get new acceleration
		vector acceldts[size];
		if (!get_accels(acceldts, mols, size)) return NULL;
		// update molecule velocities
		for (long i = 0; i < size; i++) {
			///molecules[m].vel += dt * (molecules[m].accel + acceldts[m]) / 2
			mols[i].vel.x += dt * (accels[i].x + acceldts[i].x) / 2;
			mols[i].vel.y += dt * (accels[i].y + acceldts[i].y) / 2;
			mols[i].vel.z += dt * (accels[i].z + acceldts[i].z) / 2;	
		}
	}
	// push new molecule velocities and positions back to the list
	for (long i = 0; i < size; i++) {
		PyObject *mol;
		if (!(mol = PyList_GetItem(mol_list, i))) return NULL;
		PyObject *pos, *vel;
		if (!(pos = PyObject_GetAttrString(mol, "pos"))) return NULL;
		if (!(vel = PyObject_GetAttrString(mol, "vel"))) return NULL;
		if (!set_vector(pos, &mols[i].pos)) return NULL;
		if (!set_vector(vel, &mols[i].vel)) return NULL;
		Py_DECREF(pos);
		Py_DECREF(vel);
	}
	return Py_BuildValue("l", max_steps);
}

/// list of python function exports
static PyMethodDef md_methods[] = {
	{"total_ke", total_ke, METH_VARARGS},
	{"total_pe", total_pe, METH_VARARGS},
	{"update_mols", update_mols, METH_VARARGS},
	{"", NULL, 0}
};

/// python extension initialization routine
PyMODINIT_FUNC
initmd(void)
{
	(void) Py_InitModule("md", md_methods);
}
