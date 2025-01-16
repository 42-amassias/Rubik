package com.rubik.view;

import javax.swing.JComponent;
import javax.swing.JMenuBar;
import javax.swing.JPanel;

import com.rubik.gui.IFrameLayout;

public class FrameLayout implements IFrameLayout
{

	private JPanel contentPanel;
	private JMenuBar menuBar;

	public FrameLayout()
	{
		this.contentPanel = new JPanel();
		this.menuBar = new JMenuBar();
	}

	@Override
	public JComponent getView()
	{
		return this.contentPanel;
	}

	@Override
	public JMenuBar getMenuBar()
	{
		return this.menuBar;
	}

}
