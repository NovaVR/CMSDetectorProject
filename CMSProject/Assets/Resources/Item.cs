using UnityEngine;
using System.Collections;
using System.Xml;
using System.Xml.Serialization;

public class Item {

    [XmlAttribute("name")]
    public string name;

    [XmlElement("pt")]
    public float pt;

    [XmlElement("eta")]
    public float eta;

	[XmlElement("phi")]
	public float phi;

	[XmlElement("charge")]
	public float charge;
}
