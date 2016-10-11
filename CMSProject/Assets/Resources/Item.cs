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

    [XmlElement("title")]
    public string title;

    [XmlElement("run")]
    public float run;

    [XmlElement("ev")]
    public float ev;

    [XmlElement("energy")]
    public float energy;

    [XmlElement("ls")]
    public float ls;

    [XmlElement("theta")]
    public float theta;

    [XmlElement("time")]
    public string time;

    [XmlElement("orbit")]
    public float orbit;

}
