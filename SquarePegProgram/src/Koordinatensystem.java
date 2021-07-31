import java.io.File;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.BasicStroke;
import java.awt.Stroke;
import java.awt.RenderingHints;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.event.ComponentListener;
import java.awt.event.ComponentEvent;
import java.util.Vector;
import javax.swing.JComboBox;
import javax.swing.JPanel;
import javax.swing.JLabel;
import javax.swing.JOptionPane;

public class Koordinatensystem extends JPanel //Panel
               implements MouseListener, MouseMotionListener, ComponentListener {
       
    private static final long serialVersionUID      = -3963869004200953530L;
    private final int punktRadius                   = 3;
    private final int selektierRadius               = 10;
    private final int selektierRadiusKurve          = 30;
    
    private final Color colorHintergrund            = new Color(230,230,255);
    private final Color colorPunkte                 = new Color(210,100,100);
    private final Color colorKurve                  = new Color(180,180,250);
    private final Color colorQuadrat                = new Color(250,100,100);
    private final Color colorSelektierterPunkt      = new Color(180,200,240);
    private final Color colorSelektierteKanten      = new Color(80,100,140);
    private final Color colorBewegen                = new Color(240,240,240);
    
    private final int splineSteps                   = 10;
    
    private int sichBewegenderPunkt                 = -1;
    private int punktInDerNaeheDerMaus              = -1;
    private Punkt endpunktADerKanteInDerNaeheDerMaus = null;
    private int mausX                               = 0;
    private int mausY                               = 0;
    
    private double minX                             = -10,
                   minY                             = -10,
                   maxX                             = 10,
                   maxY                             = 10;
    
    private double seitenVerhaeltnis                = 1;
    private boolean fangePunkteImmer                = true;
    
    private Vector<Punkt> punkte; //die gegebenen Punkte
    private Vector<Kante> kanten; //die Kurve die duch die Punkte geht
    private Vector<Quadrat> quadrate; //die Quadrate die auf der Kurve liegen
    
    private boolean initialisiert				   = false;
    
    public JComboBox ComboKurve;
    public JLabel LabelOutput;
    
    Koordinatensystem(JComboBox ComboKurve, JLabel LabelOutput) {
            this.ComboKurve = ComboKurve;
            this.LabelOutput = LabelOutput;
            
            setDoubleBuffered(true);
            setBackground(colorHintergrund);

            ladeStandardPunktKonfiguration();
            
            addMouseListener(this);
            addMouseMotionListener(this);
            addComponentListener(this);
            setBackground(colorHintergrund);
            initialisiert = true;
    }
    private void ladeStandardPunktKonfiguration() {
        punkte = new Vector<Punkt>();
        punkte.add(new Punkt(5,5));
        punkte.add(new Punkt(8,2));
        punkte.add(new Punkt(2,3));
//        punkte.add(new Punkt(2,5));
//        punkte.add(new Punkt(0,3));
//        punkte.add(new Punkt(8,5));
        fangePunkte();
        berechneKurve(true);
        berechneQuadrate(false);
    }
    //Zeichnen
    public void paint(Graphics g) {
 	       Graphics2D g2 = (Graphics2D)g;
 		   g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
			                       RenderingHints.VALUE_ANTIALIAS_ON);
 		   g2.setRenderingHint(RenderingHints.KEY_RENDERING,
			                       RenderingHints.VALUE_RENDER_QUALITY);
            Punkt P;
            Kante K;
            Quadrat Q;
            
            Stroke s = new BasicStroke(2);
            g2.setStroke(s);
            
            //Hintergrund zeichnen:
            g2.setColor(colorHintergrund);
            g2.fillRect(0,0,getWidth(),getHeight());
            
            //Punkte zeichnen:
            g2.setColor(colorPunkte);
            for (int i=0; i<punkte.size(); i++) {
                    P = (Punkt)punkte.get(i);
                    g2.fillOval(koordinatenInPixelX(P.x)-punktRadius,
                                    koordinatenInPixelY(P.y)-punktRadius,                                                           2*punktRadius,2*punktRadius);
            }
            //Ggf. selektierten Punkt zeichnen:
            if (sichBewegenderPunkt!=-1) {
                    g2.setColor(colorBewegen);
                    P = (Punkt)punkte.get(sichBewegenderPunkt);
                    g2.drawOval(koordinatenInPixelX(P.x)-selektierRadius,
                 		   koordinatenInPixelY(P.y)-selektierRadius,
                 		   2*selektierRadius,2*selektierRadius);
            } else
            if (punktInDerNaeheDerMaus!=-1) {
                    g2.setColor(colorSelektierterPunkt);
                    P = (Punkt)punkte.get(punktInDerNaeheDerMaus);
                    g2.drawOval(koordinatenInPixelX(P.x)-selektierRadius,
                 		      koordinatenInPixelY(P.y)-selektierRadius,
                 		      2*selektierRadius,2*selektierRadius);
            }
            //Spline zeichnen:
            for (int i=0; i<kanten.size(); i++) {
                K = (Kante)kanten.get(i);
                if (K.indexA!=endpunktADerKanteInDerNaeheDerMaus ||
             	   sichBewegenderPunkt != -1 ||
             	   punktInDerNaeheDerMaus != -1)
             	   g2.setColor(colorKurve);
                else
             	   g2.setColor(colorSelektierteKanten);
                g2.drawLine(koordinatenInPixelX(K.A.x),koordinatenInPixelY(K.A.y),koordinatenInPixelX(K.B.x),koordinatenInPixelY(K.B.y));
            }
            //Quadrate zeichnen:
            for (int i=0; i<quadrate.size(); i++) {
                Q = (Quadrat)quadrate.get(i);
            	   g2.setColor(colorQuadrat);
                g2.drawLine(koordinatenInPixelX(Q.A.x),koordinatenInPixelY(Q.A.y),koordinatenInPixelX(Q.B.x),koordinatenInPixelY(Q.B.y));
                g2.drawLine(koordinatenInPixelX(Q.B.x),koordinatenInPixelY(Q.B.y),koordinatenInPixelX(Q.C.x),koordinatenInPixelY(Q.C.y));
                g2.drawLine(koordinatenInPixelX(Q.C.x),koordinatenInPixelY(Q.C.y),koordinatenInPixelX(Q.D.x),koordinatenInPixelY(Q.D.y));
                g2.drawLine(koordinatenInPixelX(Q.D.x),koordinatenInPixelY(Q.D.y),koordinatenInPixelX(Q.A.x),koordinatenInPixelY(Q.A.y));
/*                   g2.drawOval(koordinatenInPixelX(Q.A.x)-5,
           		      koordinatenInPixelY(Q.A.y)-5,10,10);
                g2.drawOval(koordinatenInPixelX(Q.B.x)-3,
           		      koordinatenInPixelY(Q.B.y)-3,6,6);
*/
            }
            //LabelOutput.setText("Quadrate: "+quadrate.size());
            //LabelOutput.setText(punkte.toString());
    }
    
    public void mousePressed(MouseEvent e) {
            int i = ermittlePunktInDerNaeheDerMaus();
            if (e.getModifiers() == MouseEvent.BUTTON1_MASK) {
                    //Linke Maustaste gedrückt:
                    //Bewegen oder Hinzufügen eines Punktes:
                    if (i!=-1)
                            sichBewegenderPunkt = i;
                    else {
                        sichBewegenderPunkt = neuerPunkt(pixelInKoordinatenX(mausX),pixelInKoordinatenY(mausY));
                    }
                    repaint();
            } else
            if (e.getModifiers() == MouseEvent.BUTTON3_MASK) {
                    //Rechte Maustaste gedrückt:
                    //Löschen eines Punktes:
                    if (i!=-1 && punkte.size()>=4) {
                            //punkte.get((i-1)%(punkte.size())).bewegt = true;
                            punkte.get(i).bewegt = true; //wird fuer die anliegenden Kanten gebraucht
                            punkte.get((i+1)%(punkte.size())).bewegt = true;
                 	   	   punkte.remove(i);
                            sichBewegenderPunkt = -1;
                            punktInDerNaeheDerMaus = -1;
                            berechneKurve(false);
                            berechneQuadrate(false);
                            repaint();
                    }                                                      
            }
    }
    
    public void mouseMoved(MouseEvent e) {
            boolean neuZeichnen = false;
            //Speichere Mauskoordinaten:
            mausX = e.getX();
            mausY = e.getY();

            if (sichBewegenderPunkt!=-1) {
                    Punkt P = (Punkt)punkte.get(sichBewegenderPunkt);
                    P.x = pixelInKoordinatenX(mausX);
                    P.y = pixelInKoordinatenY(mausY);
                    P.bewegt = true;
                    berechneKurve(false);
                    berechneQuadrate(false);
                    neuZeichnen = true;                    
            } else {
                    int p = ermittlePunktInDerNaeheDerMaus();
                    if (p!=punktInDerNaeheDerMaus) {
                            punktInDerNaeheDerMaus = p;    
                            neuZeichnen = true;                    
                    }
            }
            
            //Falls andere Kante selektiert wurde, neuzeichnen:
            Punkt alt = endpunktADerKanteInDerNaeheDerMaus;
            ermittleKanteInDerNaeheDerMaus();
            if (alt!=endpunktADerKanteInDerNaeheDerMaus)
         	   neuZeichnen = true;
            
            if (neuZeichnen) repaint();                            
    }
    
    public void mouseDragged(MouseEvent e) {
            //Maus wurde bewegt, während ein Button gedrückt ist.
            mouseMoved(e);
    }

    public void mouseReleased(MouseEvent e) {
            sichBewegenderPunkt = -1;
            if (fangePunkteImmer)
         	   fangePunkte();
            repaint();
    }
    
    /**
     * Ermittelt den Index des Punktes der der Maus am nähesten liegt,
     * sofern einer in der Nähe (selektierRadius) liegt.
     * Liegt kein Punkt in der Nähe, wird -1 zurückgegeben.
     **/
    private int ermittlePunktInDerNaeheDerMaus() {
            int besterPunkt = -1;
            int besterAbstand = selektierRadius*selektierRadius+1;
            int abstand;
            Punkt P;
            for (int i=0; i<punkte.size(); i++) {
                    P = (Punkt)punkte.get(i);
                    abstand = (koordinatenInPixelX(P.x)-mausX)*(koordinatenInPixelX(P.x)-mausX)+
                              (koordinatenInPixelY(P.y)-mausY)*(koordinatenInPixelY(P.y)-mausY);
                    if (abstand < besterAbstand) {
                            besterAbstand = abstand;
                            besterPunkt = i;
                    }
            }              
            return besterPunkt;
    }
    
    private Kante ermittleKanteInDerNaeheDerMaus() {
        Kante besteKante = null;
        int besterAbstand = selektierRadiusKurve;
        int abstand;
        int ax, ay, bx, by;
        Kante K = null;
        endpunktADerKanteInDerNaeheDerMaus = null;
        for (int i=0; i<kanten.size(); i++) {
                K = (Kante)kanten.get(i);
                ax = koordinatenInPixelX(K.A.x);
                ay = koordinatenInPixelY(K.A.y);
                bx = koordinatenInPixelX(K.B.x);
                by = koordinatenInPixelY(K.B.y);
                double lambda = (mausX-ax)*(bx-ax)+(mausY-ay)*(by-ay);
                if (lambda<0) 
             	   abstand = (ax-mausX)*(ax-mausX)+(ay-mausY)*(ay-mausY);
                else if (lambda > (bx-ax)*(bx-ax)+(by-ay)*(by-ay))
             	   abstand = (bx-mausX)*(bx-mausX)+(by-mausY)*(by-mausY);
                else {
             	   abstand = (int)(Math.abs((ax-mausX)*(by-ay)+(ay-mausY)*(ax-bx))/
             	   			 Math.sqrt((ax-bx)*(ax-bx)+(ay-by)*(ay-by)));                	   
                }
                if ((abstand < besterAbstand) || (besterAbstand==-1)) {
                        besterAbstand = abstand;
                        besteKante = K;
                }
        }
        if (besteKante==null)
     	   endpunktADerKanteInDerNaeheDerMaus = null;
        else
     	   endpunktADerKanteInDerNaeheDerMaus = besteKante.indexA;
        return besteKante;
    }
    
    //Berechnung des Splines aus den gegebenen Punkten
    public void berechneKurve(boolean allesNeu) {
 	   Kante kante;
 	   Punkt A, B;
 	   int n = punkte.size();
 	   if (ComboKurve.getSelectedIndex()==0) 
 	   { //glatte Kurve
     	   if (kanten==null) kanten = new Vector<Kante>();
     	   //Fuer jeden bewegten Punkt, markiere auch dessen Nachbarn als bewegt:
     	   for (int i=1; i<n; i++)
     		   if (punkte.get(i).bewegt)
     			   punkte.get(i-1).bewegt = true;
     	   for (int i=n-2; i>=0; i--)
     		   if (punkte.get(i).bewegt)
     			   punkte.get(i+1).bewegt = true;
     	   if (punkte.get(0).bewegt) punkte.get(n-1).bewegt = true;
     	   if (punkte.get(n-1).bewegt) punkte.get(0).bewegt = true;
     	   //Loesche alle Kanten die der Benutzer bewegt hat:
     	   for (int i=kanten.size()-1; i>=0; i--) {
     		   kante = (Kante)kanten.get(i);
     		   if (kante.indexA.bewegt || kante.indexB.bewegt || allesNeu) {
     			   kante.bewegt = true; //wird benoetigt fuer die Quadrate, die an dieser Kante liegen
     			   kanten.remove(i);        			   
     		   }
     	   }
 		   for (int i=0; i<n; i++) {
 			   A = punkte.get(i);
 			   B = punkte.get((i+1)%n);
 			   if (A.bewegt || B.bewegt || allesNeu) {
 				   Punkt[] streckenZug = new Punkt[splineSteps+1];
 				   for (int k=0; k<=splineSteps; k++) {
 					   double t = (double)k/(double)splineSteps;
 					   double[] c = new double[4];
 					   c[0] = (((-t+3)*t-3)*t+1)/6;
 				       c[1] = (((3*t-6)*t)*t+4)/6;
 				       c[2] = (((-3*t+3)*t+3)*t+1)/6;
 				       c[3] = (t*t*t)/6;
 				       streckenZug[k] = new Punkt(0,0);
 				       for (int j=0; j<4; j++) {
 				    	   streckenZug[k].x += c[j] * punkte.get((i+j+n-1)%n).x;
 				    	   streckenZug[k].y += c[j] * punkte.get((i+j+n-1)%n).y;
 				       } 
 				   }
 				   for (int k=0; k<splineSteps; k++)
 					   kanten.add(new Kante(streckenZug[k],streckenZug[k+1],A,B));
 			   }
 		   }
 	   }
 	   else if (ComboKurve.getSelectedIndex()==1) 
 	   { //Polygon
     	   if (kanten==null) kanten = new Vector<Kante>();
     	   //Loesche alle Kanten die der Benutzer bewegt hat.
     	   for (int i=kanten.size()-1; i>=0; i--) {
     		   kante = (Kante)kanten.get(i);
     		   if (kante.indexA.bewegt || kante.indexB.bewegt || allesNeu) {
     			   kante.bewegt = true; //wird benoetigt fuer die Quadrate, die an dieser Kante liegen
     			   kanten.remove(i);        			   
     		   }
     	   }
 		   for (int i=0; i<n; i++) {
 			   A = (Punkt)punkte.get(i);
 			   B = (Punkt)punkte.get((i+1)%n);
 			   if (A.bewegt || B.bewegt || allesNeu) 
 				   kanten.add(new Kante(A,B,A,B));
 		   }
 	   }
 	   //Koennen jetzt Punkte auf nicht-bewegt setzen, da Kanten aktualisiert wurden:
 	   for (int i=0; i<n; i++) 
 		   ((Punkt)punkte.get(i)).bewegt = false;
    }
    //Berechnung der Ausgleichsgerade
    public void berechneQuadrate(boolean allesNeu) {
 	   if (quadrate==null || allesNeu)
 		   quadrate = new Vector<Quadrat>();
 	   int m = kanten.size();
 	   Kante Ki, Kj, Kk, Kl;
 	   Punkt P1, P2, P3, P4;
 	   Quadrat Q;
 	   double mx, Mx, my, My;
 	   double A1, A2, A3, A4;
 	   double b1, b2;
 	   double alpha, beta, gamma, delta;
 	   double det;
 	   double eps = 0.0000001;
 	   double r = seitenVerhaeltnis;
 	   //Loesche Quadrate, die auf bewegten Kanten liegen:
 	   for (int i=quadrate.size()-1; i>=0; i--) {
 		   Q = (Quadrat)quadrate.get(i);
 		   if (Q.indexKa.bewegt || Q.indexKb.bewegt || Q.indexKc.bewegt || Q.indexKd.bewegt)
 			   quadrate.remove(i);
 	   }
 	   //Finde neue Quadrate:
 	   for (int i=0; i<m; i++) {
 		 Ki = (Kante)kanten.get(i);
 		 if (Ki.bewegt || allesNeu) {
 		   for (int j=0; j<m; j++) {
     		   Kj = (Kante)kanten.get(j);
     		   for (int k=0; k<m; k++) {
         		   Kk = (Kante)kanten.get(k);
        			   //Pruefe zuerst, ob es moeglicherweise ein gleichschenkliges Dreieck 
       			   //auf diesen drei Kanten geben kann: (ggf. gibt es ein einfaches Hindernis: wir testen ob die Kante Kk die Boundingbox von der Drehung von Ki um alle Punkte von Kj schneidet) 
        			   P1 = Punkt.dreheAMinusNeunzigGradUmBUndSkaliere(Ki.A,Kj.A,r);
        			   P2 = Punkt.dreheAMinusNeunzigGradUmBUndSkaliere(Ki.A,Kj.B,r);
        			   P3 = Punkt.dreheAMinusNeunzigGradUmBUndSkaliere(Ki.B,Kj.A,r);
        			   P4 = Punkt.dreheAMinusNeunzigGradUmBUndSkaliere(Ki.B,Kj.B,r);
        			   mx = Math.min(P1.x,Math.min(P2.x,Math.min(P3.x,P4.x)));
        			   my = Math.min(P1.y,Math.min(P2.y,Math.min(P3.y,P4.y)));
        			   Mx = Math.max(P1.x,Math.max(P2.x,Math.max(P3.x,P4.x)));
        			   My = Math.max(P1.y,Math.max(P2.y,Math.max(P3.y,P4.y)));
        			   if ((Kk.A.x>=mx || Kk.B.x>=mx) &&
        				   (Kk.A.y>=my || Kk.B.y>=my) &&
        				   (Kk.A.x<=Mx || Kk.B.x<=Mx) &&
        				   (Kk.A.y<=My || Kk.B.y<=My)) {
        				   //Test ueberstanden, ggf. gibt es also ein Quadrat mit den ersten drei Ecken auf Ki, Kj und Kk.
        				   for (int l=0; l<m; l++) {
        					 //Testen ob mindestens drei verschiedene Kanten vorkommen:
        					 if ((i!=j && i!=k && j!=k) ||  
        						 (i!=j && i!=l && j!=l) ||
        						 (i!=k && i!=l && k!=l) ||
        						 (j!=k && j!=l && k!=l)) {
        					   Kl = (Kante)kanten.get(l);
        					   //Mache den gleichen Test nochmal:
                			   P1 = Punkt.dreheAMinusNeunzigGradUmBUndSkaliere(Kj.A,Kk.A,1/r);
                			   P2 = Punkt.dreheAMinusNeunzigGradUmBUndSkaliere(Kj.A,Kk.B,1/r);
                			   P3 = Punkt.dreheAMinusNeunzigGradUmBUndSkaliere(Kj.B,Kk.A,1/r);
                			   P4 = Punkt.dreheAMinusNeunzigGradUmBUndSkaliere(Kj.B,Kk.B,1/r);
                			   mx = Math.min(P1.x,Math.min(P2.x,Math.min(P3.x,P4.x)));
                			   my = Math.min(P1.y,Math.min(P2.y,Math.min(P3.y,P4.y)));
                			   Mx = Math.max(P1.x,Math.max(P2.x,Math.max(P3.x,P4.x)));
                			   My = Math.max(P1.y,Math.max(P2.y,Math.max(P3.y,P4.y)));
                			   if ((Kl.A.x>=mx || Kl.B.x>=mx) &&
                				   (Kl.A.y>=my || Kl.B.y>=my) &&
                				   (Kl.A.x<=Mx || Kl.B.x<=Mx) &&
                				   (Kl.A.y<=My || Kl.B.y<=My)) {
                				   //Test wieder ueberstanden, ggf. gibt es also ein Quadrat mit den vier Ecken auf Ki, Kj, Kk und Kl.
    					   		   //Loese Gleichungssystem:
                				   // ( A1  A2 ) (alpha)  =  (b1)
                				   // ( A3  A4 ) (beta )  =  (b2) 
                				   A1 = r*((Kk.A.x-Kk.B.x)*(Ki.A.x-Ki.B.x) + (Kk.B.y-Kk.A.y)*(Ki.B.y-Ki.A.y));
                				   A2 = (Kk.A.x-Kk.B.x)*(r*(Kj.B.x-Kj.A.x)-Kj.A.y+Kj.B.y) + (Kk.B.y-Kk.A.y)*(Kj.B.x-Kj.A.x+r*(Kj.A.y-Kj.B.y));
                				   A3 = (Kl.A.x-Kl.B.x)*(r*(Ki.A.x-Ki.B.x)-Ki.A.y+Ki.B.y) + (Kl.B.y-Kl.A.y)*(Ki.B.x-Ki.A.x+r*(Ki.B.y-Ki.A.y));
                 			   A4 = r*((Kl.A.x-Kl.B.x)*(Kj.B.x-Kj.A.x) + (Kl.B.y-Kl.A.y)*(Kj.A.y-Kj.B.y));
                 			   b1 = (Kk.A.y-Kk.B.y)*(r*(Ki.A.y-Kj.A.y)+Kj.A.x-Kk.A.x) + (Kk.B.x-Kk.A.x)*(r*(-Ki.A.x+Kj.A.x)+Kj.A.y-Kk.A.y);
                 			   b2 = (Kl.B.x-Kl.A.x)*(r*(-Ki.A.x+Kj.A.x)+Ki.A.y-Kl.A.y) + (Kl.A.y-Kl.B.y)*(r*(Ki.A.y-Kj.A.y)+Ki.A.x-Kl.A.x);
                 			   det = A1*A4-A2*A3;
                 			   if (det==0) det = 1;
                 			   alpha = (b1*A4-A2*b2)/det;
                 			   beta  = (A1*b2-b1*A3)/det;
                 			   if (-eps<alpha && alpha < 1+eps &&
                 				   -eps<beta  && beta  < 1+eps) {
                 				   Punkt X = new Punkt(Ki.A.x+alpha*(Ki.B.x-Ki.A.x),Ki.A.y+alpha*(Ki.B.y-Ki.A.y));
                 				   Punkt Y = new Punkt(Kj.A.x+beta *(Kj.B.x-Kj.A.x),Kj.A.y+beta *(Kj.B.y-Kj.A.y));
                 				   Punkt W = Punkt.dreheANeunzigGradUmBUndSkaliere(Y,X,r);
                 				   Punkt Z = Punkt.dreheANeunzigGradUmBUndSkaliere(X,W,1/r);
                 				   gamma = (Z.x-Kk.A.x)/(Kk.B.x-Kk.A.x);
                 				   delta = (W.x-Kl.A.x)/(Kl.B.x-Kl.A.x);
                     			   if (-eps<gamma && gamma < 1+eps &&
                         			   -eps<delta && delta < 1+eps) {
                     				   //Haben Quadrat gefunden! (bis auf eps, aber wir nehmen lieber zu viel Quadrate als zu wenig)
                     				   Q = new Quadrat(X,Y,Z,W,Ki,Kj,Kk,Kl);
                     				   quadrate.add(Q);
                     			   }
                 			   }                    			   
         				     }
        			       }
         			   }
         		   }
     		   }   
 		   }
 		 }
 	   }
 	   //Koennen Kanten als nicht-bewegt markieren, da alle Updates gemacht wurden:
 	   for (int i=0; i<m; i++) 
 		   ((Kante)kanten.get(i)).bewegt = false;
    }
    
    public void setSeitenVerhaeltnis(double seitenVerhaeltnis) {
 	   if (this.seitenVerhaeltnis != seitenVerhaeltnis) {
 		   this.seitenVerhaeltnis = seitenVerhaeltnis;
 		   berechneQuadrate(true);
 		   repaint();
 	   }
    }

    public boolean getFangePunkteImmer() {
 	   return fangePunkteImmer;
    }
    
    public void setFangePunkteImmer(boolean fangePunkteImmer) {
 	   //if (this.fangePunkteImmer==fangePunkteImmer) return;
 	   this.fangePunkteImmer = fangePunkteImmer;
 	   if (fangePunkteImmer) {
 		   fangePunkte();
 		   repaint();
 	   }
    }
    //B/erechnet die Maße des Koordinatensystems, so dass alle Punkte eingefangen werden
    public void fangePunkte() {
            if (punkte.size()==0) {
                    minX = -10;
                    minY = -10;
                    maxX = 10;
                    maxY = 10;                      
            } else {
                    Punkt P = (Punkt)punkte.get(0);
                    minX = P.x;
                    minY = P.y;
                    maxX = P.x;
                    maxY = P.y;
                    for (int i=0; i<punkte.size(); i++) {
                            P = (Punkt)punkte.get(i);
                            if (minX > P.x) minX = P.x;
                            if (minY > P.y) minY = P.y;
                            if (maxX < P.x) maxX = P.x;
                            if (maxY < P.y) maxY = P.y;
                    }
                    if (minX==maxX) {
                            minX -= 10;
                            maxX += 10;
                    } else {
                            double d=(maxX-minX)*0.1;
                            minX -= d;
                            maxX += d;
                    }                              
                    if (minY==maxY) {
                            minY -= 10;
                            maxY += 10;
                    } else {
                            double d=(maxY-minY)*0.1;
                            minY -= d;
                            maxY += d;
                    }              
            }
            //Verhaeltnis dem Fenster anpassen:
            if (!initialisiert) return; //sonst schlaegt getWidth() und getHeight() fehl!
            double faktor = (double)getWidth()/(double)getHeight()/(maxX-minX)*(maxY-minY);
            if (faktor>1) {
         	   double d=(maxX-minX)*(faktor-1)/2;
         	   maxX += d;
         	   minX -= d;            	   
            } else {
         	   double d=(maxY-minY)*(1/faktor-1)/2;
         	   maxY += d;
         	   minY -= d;            	   
            }
    }
    //Umrechnen von Koordinaten in Pixel oder umgekehrt
    public int koordinatenInPixelX(double x) {
            return (int)(getWidth()*(x-minX)/(maxX-minX));
    }
    public int koordinatenInPixelY(double y) {
            return getHeight()-(int)(getHeight()*(y-minY)/(maxY-minY));
    }
    public double pixelInKoordinatenX(int x) {
            return (maxX-minX)*(double)(x)/(double)(getWidth())+minX;
    }
    public double pixelInKoordinatenY(int y) {
            return (maxY-minY)*(double)(getHeight()-y)/(double)(getHeight())+minY;
    }
    
    //Hinzufügen eines neuen Punktes zur Punktemenge
    public int neuerPunkt(double x, double y) {
            Kante K = ermittleKanteInDerNaeheDerMaus();
            if (K==null) return -1;
            K.indexA.bewegt = true; //damit die alte Kante geloescht wird 
            Punkt P = new Punkt(x,y);
            int index = punkte.indexOf(K.indexB);
            punkte.add(index,P);
            berechneKurve(false);
            berechneQuadrate(false);
            return index;
    }
    
    public void loadFromFile(File file) {
    	Vector<Punkt> altePunkte = punkte;
    	try {
    		BufferedReader in = new BufferedReader(new FileReader(file)); 
    		punkte = new Vector<Punkt>();
    		String zeile; 
    		while ((zeile = in.readLine()) != null) { 
    			 //Jede Zeile entspricht ein Punkt:
    			if (zeile!="") {
    				zeile = zeile.trim().replace("(","").replace(")","");
    				int semikolon = zeile.indexOf(";");
    				if (semikolon != -1) {
        				double x = Double.parseDouble(zeile.substring(0,semikolon));
        				double y = Double.parseDouble(zeile.substring(semikolon+1));
        				punkte.add(new Punkt(x,y));
    				}
    			}
    		} 
    		in.close(); 
    		if (punkte.size()<=2) {
    			throw new IOException();
    		}
    		fangePunkte();
    		berechneKurve(true);
    		berechneQuadrate(false);
    		repaint();
    	} catch (IOException e) {
    		JOptionPane.showMessageDialog(this,"Could not open file "+file.getPath()+".","Error",JOptionPane.ERROR_MESSAGE);
    		punkte = altePunkte;
    	}
    	return;
    }
    
    public void saveToFile(File file) {
    	try { 
    		BufferedWriter out = new BufferedWriter(new FileWriter(file));
    		for (int i=0; i<punkte.size(); i++) {
    			out.write(punkte.get(i).toString()+"\n");
    		}
    		out.close(); 
    	} catch (IOException e) { 
    		JOptionPane.showMessageDialog(this,"Could not save to file "+file.getPath()+".","Error",JOptionPane.ERROR_MESSAGE);
    	} 
    	return;
    }

    public void componentResized(ComponentEvent e) {
    	if (fangePunkteImmer)
    		fangePunkte();
    	//repaint(); wird nicht gebraucht, das wird im Anschluss automatisch aufgerufen
    }

    
//Folgende Funktionen müssen implementiert werden (für die
//Interfaces MouseListener und MouseMotionListener):
    public void mouseClicked(MouseEvent e) {}
    public void mouseEntered(MouseEvent e) {}
    public void mouseExited(MouseEvent e) {}
    
    
//Folgende Funktionen muessen implementiert werden fuer den ComponentListener:

    public void componentHidden(ComponentEvent e) {
    }
    public void componentMoved(ComponentEvent e) {
    }
    public void componentShown(ComponentEvent e) {
    }
}