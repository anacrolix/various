#include <GL/glut.h>

void init (void) {
  glClearColor (1.0, 1.0, 1.0, 0.0);
  glMatrixMode (GL_PROJECTION);
  gluOrtho2D (0.0, 200.0, 0.0, 150.0);
}

void lineSegment (void) {
  glClear (GL_COLOR_BUFFER_BIT);
  glColor3f (1.0, 0.0, 0.0);
  glBegin (GL_LINES);
  glVertex2i (180, 15);
  glVertex2i (10, 145);
  glEnd();
  glFlush();
}

int main (int argc, char** argv) {
  glutInit (&argc, argv);
  glutInitDisplayMode (GLUT_SINGLE | GLUT_RGB);
  glutInitWindowPosition (400, 300);
  glutCreateWindow ("An Example OpenGL Program");

  init ();
  glutDisplayFunc (lineSegment);
  glutMainLoop();
  return 0;
}
