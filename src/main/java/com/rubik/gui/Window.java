package com.rubik.gui;

import java.awt.Image;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;


public class Window
{
	private static final String TITLE = "Rubik";

	private JFrame frame;
	private IFrameLayout layout;

	public Window(IFrameLayout layout)
	{
		assert layout != null;

		this.layout = layout;

		this.createModel();
		this.createView();
		this.placeComponents();
		this.createController();
		frame.revalidate();
	}

	public void display()
	{
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setLocationRelativeTo(null);
		frame.setVisible(true);
		frame.pack();
	}

	private void createModel()
	{
	}

	private void createView()
	{
		frame = new JFrame(TITLE);
		this.loadIcons();
	}

	private void placeComponents()
	{
		frame.setContentPane(layout.getView());
		frame.setJMenuBar(layout.getMenuBar());
	}

	private void createController()
	{
	}

	private void loadIcons()
	{
		try
		{
			final List<Image> icons = new ArrayList<>();
			for (int i = 16; i <= 256; i *= 2)
			{
				System.out.print("Loading " + "/icons/icon" + i + ".jpg...");
				final InputStream stream = Window.class.getResourceAsStream("/icons/icon" + i + ".jpg");
				final byte iconData[] = stream.readAllBytes();
				if (!(iconData != null && iconData.length > 0))
					System.err.println("AAAAA");
				final ImageIcon icon = new ImageIcon(iconData);
				icons.add(icon.getImage());
				System.out.println(" Done.");
			}
			frame.setIconImages(icons);
		}
		catch (Exception e)
		{
			System.out.println();
			e.printStackTrace();
		}
	}

}
