package userInterfacePack;


import java.awt.event.ActionListener;

import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;



public class MenuBar extends JMenuBar{

	private static final long serialVersionUID = 1440270813521816786L;
	
	private JMenu file;
	private JMenu help;
	private JMenu changeImage;
	private JMenuItem[] images;
	private JMenuItem exit;
	
	public MenuBar(){
		
		
		
		images = new JMenuItem[4];
		file= new JMenu("File");
		add(file);
		changeImage = new JMenu("Other Images");
		file.add(changeImage);
		
		images[0]= new JMenuItem("Image 1 - Flower");
		changeImage.add(images[0]);
		
		
		images[1]= new JMenuItem("Image 2 - L. DiCaprio");
		changeImage.add(images[1]);
		
		images[2] = new JMenuItem("Image 3 - Eiffel");
		changeImage.add(images[2]);
		
		images[3] = new JMenuItem("Image 4 - Singapore");
		changeImage.add(images[3]);
		
		
		exit = new JMenuItem("Exit");
		file.add(exit);
	
		
		help= new JMenu("Help");
		add(help);
		JMenuItem about= new JMenuItem("About");
		help.add(about);
	}
	
	
	
	public void addExitActionListenerToMenuButton(ActionListener actionlistener){
		exit.addActionListener(actionlistener);
	}
	
	public void addChangeImagActionToMenuButton(ActionListener actionlistener){
		for(int i=0; i<images.length; i++){
		images[i].addActionListener(actionlistener);
		}
	}
	
	public JMenuItem[] getImageOptions(){
		return this.images;
	}
	
}
