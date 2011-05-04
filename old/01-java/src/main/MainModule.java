package main;

import java.io.IOException;

import javax.swing.JFrame;
import javax.swing.JTree;
import javax.swing.SwingUtilities;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class MainModule {

	/**
	 * @param args
	 * @throws ParserConfigurationException 
	 * @throws IOException 
	 * @throws SAXException 
	 */
	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException {
		if (args.length < 1) {
			System.out.println(String.format("Usage: java %s <xml_file>", MainModule.class.getName()));
			System.exit(1);
		}
		
		// Read an XML file to a DOM tree.
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder parser = factory.newDocumentBuilder();
		final Document document = parser.parse(args[0]);
		
		System.out.println("Done reading file.");
		System.out.println(document.getDocumentElement().getTagName());
		
		// Display the sample window.
		SwingUtilities.invokeLater(new Runnable() {
			@Override
			public void run() {
				// Prepare an application window.
				JFrame window = new JFrame();
				window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
				window.setTitle("Scissors");
				window.setSize(400, 300);
				
				// Prepare a JTree component.
				JTree tree = new JTree(new XmlTreeModel(document));
				window.add(tree);
				
				window.setVisible(true);
			}
		});
	}

}
