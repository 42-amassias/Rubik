package com.rubik.gui;

import javax.swing.JFrame;

public class Window
{
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
		frame = new JFrame();
	}

	private void placeComponents()
	{
		frame.setContentPane(layout.getView());
		frame.setJMenuBar(layout.getMenuBar());
	}

	private void createController()
	{
	}

}
