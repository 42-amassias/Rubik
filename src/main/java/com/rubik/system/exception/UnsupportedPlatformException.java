package com.rubik.system.exception;

import com.rubik.system.System;

public class UnsupportedPlatformException
	extends Exception
{
	public UnsupportedPlatformException()
	{
		super("Platform \"" +  System.PLATFORM + "\" is not supported.");
	}
}
