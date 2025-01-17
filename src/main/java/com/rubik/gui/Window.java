package com.rubik.gui;

import java.awt.Image;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.swing.ImageIcon;
import javax.swing.JFrame;

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
		final List<Image> icons = new ArrayList<>();
		String iconPath;
		InputStream stream;
		ImageIcon icon;
		byte iconData[];

		for (int i = 16; i <= 256; i *= 2)
		{
			try
			{
				iconPath = "/icons/icon" + i + ".jpg";
				stream = Window.class.getResourceAsStream(iconPath);
				iconData = stream.readAllBytes();
				icon = new ImageIcon(iconData);
				icons.add(icon.getImage());
			}
			catch (Exception e)
			{
				System.err.printf("Could not load %dx%d icon\n", i, i);
			}
		}
		frame.setIconImages(icons);
	}

}
