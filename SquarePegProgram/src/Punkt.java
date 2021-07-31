//import java.math.*;

public class Punkt {
       double x;
       double y;
       boolean bewegt;
       
       Punkt (double x, double y) {
               this.x = x; //+Math.random()*0.000000000001;
               this.y = y; //+Math.random()*0.000000000001;
               this.bewegt = true;
       }
       public static Punkt dreheANeunzigGradUmBUndSkaliere(Punkt A, Punkt B, double faktor) {
    	   return new Punkt(B.x+faktor*(B.y-A.y),B.y+faktor*(A.x-B.x));    	   
       }
       public static Punkt dreheAMinusNeunzigGradUmBUndSkaliere(Punkt A, Punkt B, double faktor) {
    	   return new Punkt(B.x+faktor*(-B.y+A.y),B.y+faktor*(-A.x+B.x));    	   
       }
       public String toString() {
    	   return "("+x+";"+y+")";
       }

}