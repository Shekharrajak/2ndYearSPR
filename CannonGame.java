import java.awt.*;
import java.awt.event.*;
import java.lang.Math;
import java.lang.Integer;

public class CannonGame extends Frame
{
	MyCanvas c = new MyCanvas();
  	//CannonFrame frame;

	public CannonGame()
    {
		//GUI placement
		setSize(600, 350);
		setTitle("Cannon Game");
		setLayout(new BorderLayout());
		addWindowListener(new WindowAdapter()
		{
			public void windowClosing(WindowEvent e)
			{
				System.exit(0);
			}
		});
		
		c.setSize(600, 300);
		c.setBackground(Color.yellow);
		add(c, "Center");

    }
			

	public static void main(String[] args)
	{
		CannonGame game = new CannonGame();
		game.setVisible(true);
	}
}

class MyCanvas extends Canvas
{
	double dx, dy, theta, velocity, gravity, windage;
  	int xmax, ymax, numshots;
  	Color black, erase;
  	double x, y;
  	double xo[] = new double[4];
  	double yo[] = new double[4];
  	double rads;
	Graphics drawarea;
	Image targ, can, shot, bang1;
	CannonFrame frame;
	int score = 0;	
	
	public MyCanvas()
	{
		loadImages();
      	numshots = 4;
      	rads = 57.29577866f;
      	xmax = 600;
      	ymax = 300;
      	//resize(xmax,ymax+20); //deprecated method
      	theta = 60;		// degrees
      	theta /= rads;		// -> radians
      	velocity = 3;		// m/s x 10^-1
      	gravity = .098f;		// m/s^2 x 10^-2
      	windage = 0;
      	black = Color.black;
      	erase = Color.blue;
		frame = new CannonFrame(this);
		frame.setVisible(true);
		repaint();
	}

	public void more()
    {
    	numshots = 4;
    	repaint();
    }

	public void shootShot()
    {
      	if (numshots > 0)
		{
	  		numshots--;
	  		repaint();
		}
    }

	public void loadImages()
	{
		Toolkit t = getToolkit();
		can = t.getImage("cannon3.gif");
		targ = t.getImage("targ1.gif");
		shot = t.getImage("ammo2.gif");
		bang1 = t.getImage("fireball.gif");
	}

	public void changeAngle(int val)
    {
      	Integer temp = new Integer(val);
      	theta = (double)val;		// degrees
      	theta /= rads;		// -> radians
      	frame.ang.setText(temp.toString());
    }

  	public void changeVelocity(int val)
    {
      	Integer temp = new Integer(val);
      	velocity = (double)val / 5;
      	frame.vel.setText(temp.toString());
    }

  	public void changeGravity(int val)
    {
      	Float temp = new Float((float)val / 10);
      	gravity = (double)val / 1000;
      	frame.grav.setText(temp.toString());
    }

  	public void changeWindage(int val)
    {
      	Integer temp = new Integer(val);
      	windage = (double)val / 200;
      	frame.wind.setText(temp.toString());
    }

	public void paint(Graphics g)
    {
      	if (can == null) 
	  	{
	  		return;
      	}

      	//drawarea = g;
      	//##### Cannon part

      	//##### Draw images
      	g.drawImage(can, 20, ymax - can.getHeight(this), this);
      	g.drawImage(targ, xmax - (targ.getWidth(this) + 10), ymax - targ.getHeight(this), this);
      	if (numshots > 3) 
	  		g.drawImage(shot, 0, ymax - ((2*shot.getHeight(this))+2), this);
      	if (numshots > 2) 
			g.drawImage(shot, 2 + shot.getWidth(this), ymax - ((2*shot.getHeight(this))+2), this);
      	if (numshots > 1) 
			g.drawImage(shot, 0, ymax - shot.getHeight(this), this);
      	if (numshots  >0) 
			g.drawImage(shot, 2 + shot.getWidth(this), ymax - shot.getHeight(this), this);

      	if (numshots < 4)
		{
	  		//##### Shoot da shot
	  		x = 65;
	  		y = ymax-55;
	  		dx = velocity * Math.cos(theta);
	  		dy = velocity * Math.sin(theta);
	  		g.setColor(Color.gray);
	  
	  		while ((x > 0) && (x < xmax) && (y < ymax))
	    	{
	      		if (xo[3] != 0)
					g.clearRect((int)xo[3] - 4, (int)yo[3] - 4, 8, 7);
	      		if (xo[0] != 0)
		  			g.drawRect((int)xo[0]-1, (int)yo[0]-1, 2, 2);
	      		g.drawImage(shot, (int)x - 4, (int)y - 4, this);
	      		if (x < 75) 
					g.drawImage(can, 20, ymax - can.getHeight(this), this);
	      		if ((x>xmax-(targ.getWidth(this)+10)) && (y>ymax-targ.getHeight(this)))
					g.drawImage(targ, xmax - (targ.getWidth(this)+10), 
			    		ymax - targ.getHeight(this), this);
				try {Thread.sleep(5);}catch(InterruptedException ex){}
	      		xo[0] = xo[1]; xo[1] = xo[2]; xo[2] = xo[3];
	      		yo[0] = yo[1]; yo[1] = yo[2]; yo[2] = yo[3];
	      		xo[3] = x; yo[3] = y;
	      		x += dx;
	      		dx -= windage/2;
	      		y -= dy;
	      		dy -= gravity/2;
	      
	      		//##### Check for hit
	      		if ((x>(xmax-43)) && (x<(xmax-27)) && 
		  			(y>(ymax-40)) && (y<(ymax-25)))
				{
		  			//g.drawImage(bang1, xmax - (bang1.getWidth(this)+10), 
			    	//	ymax - bang1.getHeight(this), this);
					++score;
					frame.tfScore.setText("" + score);
				}
	    	}
	  		for (int i=0; i<4; i++) 
				xo[i] = yo[i] = 0;
		}
    }
}

class CannonFrame extends Frame
	implements ActionListener, AdjustmentListener 
{
	MyCanvas can;
	//int score = 0;
    TextField ang;
    TextField vel;
    TextField grav;
    TextField wind;
	TextField tfScore;

	Button btShoot, btAmmo;

    Scrollbar s_ang;
    Scrollbar s_vel;
    Scrollbar s_grav;
    Scrollbar s_wind;

    CannonFrame(MyCanvas can) 
	{
		this.can = can;

		setTitle("Cannon");

		Panel p;
		add("North", p = new Panel());

		p.add(new Label("Ang:"));
		p.add(ang = new TextField("60", 4));
		ang.setEditable(false);

		p.add(new Label("Vel:"));
		p.add(vel = new TextField("15", 4));
		vel.setEditable(false);

		p.add(new Label("Grav:"));
		p.add(grav = new TextField("9.8", 4));
		grav.setEditable(false);

		p.add(new Label("Wind:"));
		p.add(wind = new TextField("0", 4));
		wind.setEditable(false);

		add("Center", p = new Panel());
		p.setLayout(new GridLayout(4, 0));

		p.add(s_ang = new Scrollbar(Scrollbar.HORIZONTAL));
		s_ang.setValues(60, 10, 1, 90);

		p.add(s_vel = new Scrollbar(Scrollbar.HORIZONTAL));
		s_vel.setValues(10, 2, 1, 30);

		p.add(s_grav = new Scrollbar(Scrollbar.HORIZONTAL));
		s_grav.setValues(98, 10, 40, 200);

		p.add(s_wind = new Scrollbar(Scrollbar.HORIZONTAL));
		s_wind.setValues(0, 1, -10, 10);

		s_ang.addAdjustmentListener(this);
		s_vel.addAdjustmentListener(this);
		s_grav.addAdjustmentListener(this);
		s_wind.addAdjustmentListener(this);
		
		tfScore = new TextField(5);
		tfScore.setEditable(false);
		btShoot = new Button("Shoot");
		btAmmo = new Button("More Ammo");
		btShoot.addActionListener(this);
		btAmmo.addActionListener(this);
		tfScore.setText("" + can.score);
		tfScore.addActionListener(this);
		add("South", p = new Panel());
		p.add(btShoot);
		p.add(btAmmo);
		p.add(new Label("Score:"));
		p.add(tfScore);
		pack();
    }

    public void actionPerformed(ActionEvent evt) 
	{
		String actionCommand = evt.getActionCommand();

		if ("Shoot".equals(actionCommand)) 
		{
	    	can.shootShot();
		}
		if ("More Ammo".equals(actionCommand)) 
		{
	    	can.more();
		}
    }

	public void adjustmentValueChanged(AdjustmentEvent evt)
	{
		if (evt.getSource() == s_ang) 
		{
	    	can.changeAngle(evt.getValue());
		}
		if (evt.getSource() == s_vel) 
		{
	    	can.changeVelocity(evt.getValue());
		}
		if (evt.getSource() == s_grav) 
		{
	    	can.changeGravity(evt.getValue());
		}
		if (evt.getSource() == s_wind) 
		{
	    	can.changeWindage(evt.getValue());
		}
	}
}