package com.rubik.view;

import java.awt.Dimension;

import javax.swing.JComponent;
import javax.swing.JMenuBar;
import javax.swing.JPanel;

import com.jogamp.opengl.GLCapabilities;
import com.jogamp.opengl.GLProfile;
import com.jogamp.opengl.awt.GLCanvas;
import com.rubik.gui.IFrameLayout;

public class FrameLayout implements IFrameLayout
{

	private GLProfile glProfile;
	private GLCapabilities glCapabilities;

	private JPanel contentPanel;
	private JMenuBar menuBar;
	private GLCanvas canvas;

	public FrameLayout()
	{
		this.initGL();
		this.createView();
		this.placeComponents();
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

	private void initGL()
	{
		this.glProfile = GLProfile.get(GLProfile.GL2);
		this.glCapabilities = new GLCapabilities(glProfile);
	}

	private void createView()
	{
		this.contentPanel = new JPanel();
		this.menuBar = new JMenuBar();
		this.canvas = new GLCanvas(this.glCapabilities);
		this.canvas.addGLEventListener(new RubikCanvas());
	}

	private void placeComponents()
	{
		this.canvas.setPreferredSize(new Dimension(500, 500));
		this.contentPanel.add(this.canvas);
	}

}
