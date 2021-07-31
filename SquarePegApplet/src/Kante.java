
public class Kante {
	Punkt A; //Randpunkt 1
	Punkt B; //Randpunkt 2
	Punkt indexA; //naehester vom Benutzer gesetzter Punkt 1 (i.A. kein Randpunkt!)
	Punkt indexB; //naehester vom Benutzer gesetzter Punkt 2 (i.A. kein Randpunkt!)
	boolean bewegt;
	
	Kante(Punkt A, Punkt B, Punkt indexA, Punkt indexB) {
		this.A = A;
		this.B = B;
		this.indexA = indexA;
		this.indexB = indexB;
		this.bewegt = true;
	}
}
