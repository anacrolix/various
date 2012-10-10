package dep

type bleh struct {
	hi int
}

func (me bleh) meh() string {
	if me == (bleh{}) {
		return "0"
	}
	return "1"
}

func Meh() {
	(bleh{}).meh()
}
