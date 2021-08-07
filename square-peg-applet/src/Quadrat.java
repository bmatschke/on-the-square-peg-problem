
public class Quadrat {
	Punkt A; //Ecke vom Quadrat
	Punkt B;
	Punkt C;
	Punkt D;
	Kante indexKa; //Referenz auf die Kante, die den Punkt A enthaelt.
	Kante indexKb;
	Kante indexKc;
	Kante indexKd;
	Quadrat(Punkt A, Punkt B, Punkt C, Punkt D, 
			Kante indexKa, Kante indexKb, Kante indexKc, Kante indexKd) {
		this.A = A;
		this.B = B;
		this.C = C;
		this.D = D;
		this.indexKa = indexKa;
		this.indexKb = indexKb;
		this.indexKc = indexKc;
		this.indexKd = indexKd;
	}
}
