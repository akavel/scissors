package main;

import javax.swing.event.TreeModelListener;
import javax.swing.tree.TreeModel;
import javax.swing.tree.TreePath;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

public class XmlTreeModel implements TreeModel {
	
	public XmlTreeModel(Document document) {
		this.document = document;
	}
	
	private Document document;

	@Override
	public void addTreeModelListener(TreeModelListener l) {
		// TODO Auto-generated method stub

	}

	@Override
	public Object getChild(Object parent, int index) {
		Node parentNode = (Node) parent;
		return parentNode.getChildNodes().item(index);
	}

	@Override
	public int getChildCount(Object parent) {
		Node parentNode = (Node) parent;
		return parentNode.getChildNodes().getLength();
	}

	@Override
	public int getIndexOfChild(Object parent, Object child) {
		if (parent == null || child == null) // required by the specification
			return -1;
		Node parentNode = (Node) parent;
//		Node childNode = (Node) child;
		Node pointer = parentNode.getFirstChild();
		int i=0;
		while (pointer != child && pointer != null) {
			pointer = pointer.getNextSibling();
			i++;
		}
		
		if (pointer != null)
			return i;
		else
			return -1;
	}

	@Override
	public Object getRoot() {
		return document.getDocumentElement();
	}

	@Override
	public boolean isLeaf(Object node) {
		Node nNode = (Node) node;
		short type = nNode.getNodeType();
		return !(type == Node.DOCUMENT_NODE || type == Node.ELEMENT_NODE);
	}

	@Override
	public void removeTreeModelListener(TreeModelListener l) {
		// TODO Auto-generated method stub

	}

	@Override
	public void valueForPathChanged(TreePath path, Object newValue) {
		// TODO Auto-generated method stub

	}

}
