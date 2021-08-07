//<applet code=SquarePeg.class width=400 height=300></applet>

import java.applet.Applet;
import java.awt.*;
import java.awt.event.*;
import java.io.IOException;
import java.io.File;

//import javax.swing.*;
import javax.swing.event.*;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JCheckBox;
import javax.swing.JSlider;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.UIManager;
//import javax.swing.JFrame;
import javax.swing.SwingUtilities;

public class SquarePegApplet 
                extends Applet
                //extends JFrame
{
    private static final long serialVersionUID      = 2608276476789466310L;
    JLabel labelKurve, labelOutput;  
    JCheckBox checkboxFangePunkte;
    JButton buttonNeu, buttonOpen, buttonSave, buttonHelp;
    JFileChooser fileChooser;
    JComboBox comboKurve;
    JSlider sliderSeitenVerhaeltnis;
    private Koordinatensystem kordi                 = null;
    Panel panelOben;
    Panel panelUnten;
    private final Color colorHintergrund            = new Color(220,220,250);
    private final Color colorText                   = new Color(23,13,15);
    
/*    public static void main(String[] args) {
        SquarePegApplet SP = new SquarePegApplet();
        SP.setSize(300, 300);
        //SP.setTitle("Square Peg");
        //SP.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        SP.init();
        SP.setVisible(true);
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                //setVisible(true);
            }
        });
    }
*/    
    //Folgende Funktion buendelt alle Komponenten, die im Applet ggf. nicht angezeigt werden,
    //oder sogar das Applet nicht starten lassen, da sie auf Dateien zugreifen:
    private void initKritischeIOKomponenten() {
        try {
            UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
         } catch (Exception e) {
             e.printStackTrace();
         }
         try {
             fileChooser = new JFileChooser();
             if (fileChooser!=null) {
                  String[] erweiterungen = {"pts"};
                  MeinFileFilter filter = new MeinFileFilter(erweiterungen,"File containing list of points (*.pts)");
                  fileChooser.setFileFilter(filter);

                  buttonSave = new JButton ("Save");
                 buttonSave.setBackground(colorHintergrund);
                 buttonSave.addActionListener(
                         new ActionListener() {
                                 public void actionPerformed(ActionEvent e) {
                                   try {
                                     if (fileChooser==null)
                                         throw new IOException("This applet has probably no access to the file system.");
                                      if (fileChooser.showSaveDialog(SquarePegApplet.this) == JFileChooser.APPROVE_OPTION) {
                                         File f = fileChooser.getSelectedFile();
                                         if (f.exists()) {
                                             if (JOptionPane.showConfirmDialog(buttonSave,f.getName()+" already exists. \nDo you want to overwrite it?", "Overwrite it?",JOptionPane.YES_NO_CANCEL_OPTION)
                                                     == JOptionPane.YES_OPTION)
                                                 kordi.saveToFile(f);
                                         } else
                                             kordi.saveToFile(f);
                                      }
                                   } catch (Exception exc) {
                                       exc.printStackTrace();
                                       JOptionPane.showMessageDialog(SquarePegApplet.this,exc.getLocalizedMessage(),"Error",JOptionPane.ERROR_MESSAGE);
                                   }
                                 }
                         }
                 );
                 buttonOpen = new JButton ("Open");
                 buttonOpen.setBackground(colorHintergrund);
                 buttonOpen.addActionListener(
                         new ActionListener() {
                                 public void actionPerformed(ActionEvent e) {
                                     try {
                                         if (fileChooser==null)
                                             throw new IOException("This applet has probably no access to the file system.");
                                         if (fileChooser.showOpenDialog(SquarePegApplet.this) == JFileChooser.APPROVE_OPTION) {
                                             kordi.loadFromFile(fileChooser.getSelectedFile());
                                         }
                                     } catch (Exception exc) {
                                         exc.printStackTrace();
                                         JOptionPane.showMessageDialog(SquarePegApplet.this,exc.getLocalizedMessage(),"Error",JOptionPane.ERROR_MESSAGE);
                                     }
                                 }
                         }
                 );
             } else {
//                 JOptionPane.showMessageDialog(SquarePegApplet.this,"Kann JFileChooser nicht kreieren!\nD.h. laden und speichern von Punkten ist leider nicht moeglich.","Fehler",JOptionPane.ERROR_MESSAGE);
             }
         } catch (Exception e) {
             e.printStackTrace();
         }     
    }
    
    //initiert Layout, Textfelder, Labels, Buttons und das Koordinatensystem
    public void init() {
        initKritischeIOKomponenten();
        setLayout(new BorderLayout());
        setBackground(colorHintergrund);
        setForeground(colorText);
        setFont(new Font ("Bitstream Vera Serif", Font.ITALIC, 13));
        sliderSeitenVerhaeltnis = new JSlider(JSlider.HORIZONTAL,1,1000,1000);
        sliderSeitenVerhaeltnis.setBackground(colorHintergrund);
        //sliderAspectRatio.setWidth(50);
        sliderSeitenVerhaeltnis.addChangeListener(
                new ChangeListener() {
                        public void stateChanged(ChangeEvent e) {
                            kordi.setSeitenVerhaeltnis(sliderSeitenVerhaeltnis.getValue()*0.001);
                        }
                }
        );
        checkboxFangePunkte = new JCheckBox ("Catch points!",true);
        checkboxFangePunkte.setBackground(colorHintergrund);
        checkboxFangePunkte.addChangeListener(
                new ChangeListener() {
                        public void stateChanged(ChangeEvent e) {
                            kordi.setFangePunkteImmer(checkboxFangePunkte.isSelected());
                        }
                }
        );
        labelKurve = new JLabel("Kurve",Label.LEFT);
        comboKurve = new JComboBox();
        comboKurve.addItem(" Smooth curve ");
        comboKurve.addItem(" Polygon ");
        comboKurve.addActionListener(
                new ActionListener() {
                        public void actionPerformed(ActionEvent e) {
                                   kordi.berechneKurve(true);
                               kordi.berechneQuadrate(false);
                               kordi.repaint();
                        }
                }
        );
        buttonNeu = new JButton ("Restart");
        buttonNeu.setBackground(colorHintergrund);
        buttonNeu.addActionListener(
                new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        kordi.ladeStandardPunktKonfiguration();
                        kordi.repaint();
                    }
                }
        );
        buttonHelp = new JButton ("Info");
        buttonHelp.setBackground(colorHintergrund);
        buttonHelp.addActionListener(
                new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        String msg = "Usage:\n"+
                            " - add and move points with left mouse button\n"+
                            " - delete points with right mouse button\n"+
                            "Contact:\n"+
                            " - www.math.tu-berlin.de/~matschke\n"+
                            "(c) Benjamin Matschke 2010";
                           JOptionPane.showMessageDialog(SquarePegApplet.this,
                                   msg,"Info",JOptionPane.INFORMATION_MESSAGE);
                    }
                }
        );
        labelOutput = new JLabel("(c) Benjamin Matschke 2010",Label.LEFT);
        panelOben = new Panel();
        panelOben.setBackground(colorHintergrund);
        panelUnten = new Panel();
        panelUnten.setBackground(colorHintergrund);
        panelOben.add(sliderSeitenVerhaeltnis);
        panelOben.add(checkboxFangePunkte);
        //panelUnten.add(LabelKurve);
        panelOben.add(comboKurve);

        
        panelUnten.add(buttonNeu);
        if (buttonOpen!=null) panelUnten.add(buttonOpen);
        if (buttonSave!=null) panelUnten.add(buttonSave);
        panelUnten.add(buttonHelp);
        //panelUnten.add(labelOutput);
                        
        add("North",panelOben);
        add("South",panelUnten);
        kordi = new Koordinatensystem(comboKurve, labelOutput);
        add("Center",kordi);
        
        setBackground(kordi.getBackground());
        //LabelOutput.setForeground(Kordi.getBackground());
        labelOutput.setForeground(Color.white);
        
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                //kordi.fangePunkte();
            }
        });
        
    }
}
