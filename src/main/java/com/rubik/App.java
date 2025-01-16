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
		if (args.length == 0)
		{
			System.err.println("Missing arguments.");
			System.exit(1);
		}
		if (args[0].equals("gui"))
			App.startGUI(args);
		else
			App.startCLI(args);
	}

	private static void startGUI(String[] args)
	{
		if (args.length > 1)
		{
			System.err.println("Too many arguments.");
			System.exit(1);
		}
		SwingUtilities.invokeLater(new App());
	}

	private static void startCLI(String[] args)
	{
		System.out.println("WIP.");
	}

}
