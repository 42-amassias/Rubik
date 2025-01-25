package com.rubik.view;

import com.jogamp.opengl.GL2;
import com.jogamp.opengl.GLAutoDrawable;
import com.jogamp.opengl.GLEventListener;

public class RubikCanvas implements GLEventListener
{

	@Override
	public void display(GLAutoDrawable drawable)
	{
		final GL2 gl2 = drawable.getGL().getGL2();
		gl2.glBegin(GL2.GL_QUADS);
		gl2.glColor3f(1, 0, 0);
		gl2.glVertex2f(-0.5f, -0.5f);
		gl2.glVertex2f( 0.5f, -0.5f);
		gl2.glVertex2f( 0.5f,  0.5f);
		gl2.glVertex2f(-0.5f,  0.5f);
		gl2.glEnd();
	}

	@Override
	public void dispose(GLAutoDrawable drawable)
	{
	}

	@Override
	public void init(GLAutoDrawable drawable)
	{
	}

	@Override
	public void reshape(GLAutoDrawable drawable, int x, int y, int width, int height)
	{
		final GL2 gl2 = drawable.getGL().getGL2();
		gl2.glViewport(0, 0, width, height);
	}

}
