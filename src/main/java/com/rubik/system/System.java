package com.rubik.system;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.function.Consumer;
import java.util.Iterator;
import java.util.Map;

import com.rubik.App;
import com.rubik.system.exception.UnsupportedPlatformException;

public class System
{
	public static final String PLATFORM = getPlatform();

	private static final String NATIVES_DIR = "natives";
	private static final String LIBRARIES_PATH = NATIVES_DIR + "/" + PLATFORM;

	private static boolean hasHadError = false;
	private static IOException ioExeption = null;

	private System()
	{}

	public static void loadDynalicLibraries()
		throws UnsupportedPlatformException, URISyntaxException, IOException
	{
		java.lang.System.out.println("RUNNING ON PLATFORM " + PLATFORM);

		final URI dynamicLibrariesURI = getDynamicLibrariesURI();

		// Check is the app is run via a jar or has been extracted
		if (!dynamicLibrariesURI.getScheme().equals("jar"))
			return ;

		// Natives directory creation
		createTemporaryDirectory(NATIVES_DIR);
		createTemporaryDirectory(LIBRARIES_PATH);

		// Extract dynamic libraries from the corresponding folder
		getLibraries(dynamicLibrariesURI).forEachRemaining(new LibraryCopier());

		// Throw error if one occured while copying
		if (System.hasHadError)
			throw System.ioExeption;
	}

	private static String getPlatform()
	{
		final String arch = java.lang.System.getProperty("os.arch");
		String os = java.lang.System.getProperty("os.name", "generic").toLowerCase();

		if (os.startsWith("win"))
			os = "windows";
		else if (os.contains("nix") || os.contains("nux") || os.contains("aix"))
			os = "linux";
		else if (os.contains("mac"))
			os = "macosx";
		return (os + "-" + arch);
	}

	private static URI getDynamicLibrariesURI()
		throws UnsupportedPlatformException, URISyntaxException
	{
		final URL url = App.class.getResource("/" + LIBRARIES_PATH);
		if (url == null)
			throw new UnsupportedPlatformException();
		return (url.toURI());
	}

	private static File createTemporaryDirectory(String path)
		throws IOException
	{
		final File directory = new File(path);
		directory.mkdir();
		if (!directory.exists())
			throw new IOException("Could not create directory \"" + path + "\"");
		directory.deleteOnExit();
		return (directory);
	}

	private static Iterator<Path> getLibraries(URI dynamicLibrariesURI)
		throws IOException
	{
		final Map<String, Object> emptyMap = Collections.<String, Object>emptyMap();
		final FileSystem fs = FileSystems.newFileSystem(dynamicLibrariesURI, emptyMap);
		final Path librariesPath =  fs.getPath(LIBRARIES_PATH);
		return (Files.walk(librariesPath, 1).iterator());
	}

	private static class LibraryCopier
		implements Consumer<Path>
	{
		public void accept(Path path)
		{
			if (System.hasHadError)
				return ;

			final Path library = path.getFileName();

			if (library.toString().equals(PLATFORM))
				return ;

			final File libraryFile = new File(LIBRARIES_PATH + "/" + library);
			final String jarLibraryPath = "/" + path.toString();
			LibraryCopier.copyLibrary(jarLibraryPath, libraryFile);
			libraryFile.deleteOnExit();
		}

		private static void copyLibrary(String inputPath, File outFile)
		{
			try (FileOutputStream fos = new FileOutputStream(outFile))
			{
				outFile.createNewFile();
				try (InputStream is = App.class.getResourceAsStream(inputPath))
				{
					is.transferTo(fos);
				}
			} catch (IOException e)
			{
				System.hasHadError = true;
				System.ioExeption = e;
			}
		}
	}
}
