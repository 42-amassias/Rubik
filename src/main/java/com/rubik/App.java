package com.rubik;

import javax.swing.SwingUtilities;

import com.rubik.gui.IFrameLayout;
import com.rubik.gui.Window;
import com.rubik.view.FrameLayout;

public class App implements Runnable
{

	public static final String OS_NAME = System.getProperty("os.name").toLowerCase();
	public static final String OS_ARCH = System.getProperty("os.arch");
	public static final String PLATFORM = OS_NAME + "-" + OS_ARCH;

	@Override
	public void run()
	{
		IFrameLayout layout = new FrameLayout();
		new Window(layout).display();
	}

	public static void main(String[] args) throws Exception
	{
		com.rubik.system.System.loadDynalicLibraries();

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
