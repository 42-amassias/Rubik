package com.rubik;

import javax.swing.SwingUtilities;

import com.rubik.gui.IFrameLayout;
import com.rubik.gui.Window;
import com.rubik.view.FrameLayout;

public class App implements Runnable
{

	@Override
	public void run()
	{
		IFrameLayout layout = new FrameLayout();
		new Window(layout).display();
	}

	public static void main(String[] args)
	{
		SwingUtilities.invokeLater(new App());
	}

}
