//This script allows the player to scroll between the different events for the detector
//Created by Oliver Lykken

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Serialization;
using UnityEngine.UI;
using VRTK;

public class EventScroller : MonoBehaviour {

	public GameObject[] eventArea;
	public GameObject area;

	public GameObject[] events;
	public GameObject[] event_collection;
	public GameObject currentEvent;
	GameObject this_event;
	GameObject this_sub_event;
	int lastEvent;
	int eventNumber = 0;
	int num_events = 0;

	public Object[] jsons;
	public Object[] event_folders;
	public string event_name;
	public string event_path;
	public string xml_path;


	void Start () {

		//Gets the Detector pieces that are where the events happen and puts them in an array
		eventArea = GameObject.FindGameObjectsWithTag ("eventArea")
			.Cast<GameObject> ()
			.ToArray ();

		//Gets the events and the related data from the xml files
		event_folders = Resources.LoadAll ("xml");
		num_events = event_folders.Length;
		events = new GameObject[num_events];

		//Gets the relevent data for each event
		foreach (Object obj in event_folders) {
			event_name = obj.name;
			Debug.Log (event_name);
			event_path = "events/" + event_name;
			xml_path = "xml/" + event_name;
			Debug.Log ("event_path = " + event_path);
			Debug.Log ("xml_path = " + xml_path);

			//Creates the larger event GameObject
			GameObject this_event = new GameObject ();
			this_event.transform.position = new Vector3 (0, -119.9f, 0);
			ItemContainer ic = new ItemContainer ();
			ic = ItemContainer.Load(xml_path);
			event_collection = Resources.LoadAll(event_path, typeof(GameObject))
				.Cast<GameObject>()
				.ToArray();

			//Createst the parts of the events that the data is attached to
			foreach (GameObject sub_event in event_collection) {
				GameObject this_sub_event = Instantiate (sub_event) as GameObject;
				this_sub_event.transform.position = new Vector3 (0, -119.9f, 0);
				this_sub_event.transform.localScale = new Vector3 (50f, 50f, 50f);
				this_sub_event.transform.parent = this_event.transform;
				this_sub_event.tag = "Track"; // default
                Mesh m = this_sub_event.GetComponentInChildren<MeshFilter> ().sharedMesh;
				this_sub_event.AddComponent<MeshCollider> ();
				this_sub_event.GetComponent<MeshCollider> ().sharedMesh = m;
                if (m.vertexCount > 3)
                {
                    Debug.Log(this_sub_event.ToString());
                    Debug.Log("Found mesh with " + m.vertexCount + " vertices and " + m.triangles.Length + "triangles");
                    this_sub_event.GetComponent<MeshCollider>().convex = true;
                }
                else
                {
                    this_sub_event.GetComponent<MeshCollider>().convex = false;
                }
                this_sub_event.GetComponent<MeshCollider> ().isTrigger = true;
                this_sub_event.AddComponent<VRTK_InteractableObject>();
                this_sub_event.GetComponent<VRTK_InteractableObject>().highlightOnTouch = true;
                this_sub_event.GetComponent<VRTK_InteractableObject>().touchHighlightColor = Color.green;

                //Creates the canvases where the data for each sub part of the event will be attached
                foreach (Item item in ic.items) {
					if (this_sub_event.name.Contains(item.name +"(Clone)")) {
						GameObject infocanvas = new GameObject ("InfoCanvas");
                        infocanvas.AddComponent<VRTK_InteractableObject>();
                        infocanvas.GetComponent<VRTK_InteractableObject>().isGrabbable =true;
                        infocanvas.GetComponent<VRTK_InteractableObject>().isDroppable = true;
                        infocanvas.GetComponent<VRTK_InteractableObject>().grabAttachMechanic = VRTK_InteractableObject.GrabAttachType.Child_Of_Controller;
                        infocanvas.AddComponent<Canvas> ();
						infocanvas.AddComponent<GraphicRaycaster> ();
						infocanvas.AddComponent<CanvasScaler> ();
						infocanvas.tag = "InfoCanvas";
                        infocanvas.transform.position = new Vector3(0, 0f, 0);
                        infocanvas.transform.localScale = new Vector3(0.0018f, 0.0022f, 0.01f);
                        infocanvas.transform.parent = this_sub_event.transform;
                        this_sub_event.tag = item.title;
                        GameObject text = new GameObject ("Text");
						Text infotext = text.AddComponent<Text> ();
                        switch (item.title)
                        {
                            case "CMS Event":
                                infotext.text = item.title + "\n"
                                              + " run = " + item.run + "\n"
                                              + " event = " + item.ev + "\n"
                                              + " ls = " + item.ls + "\n"
                                              + " orbit = " + item.orbit + "\n"
                                              + " time = " + item.time + "\n";
                                break;
                            case "HB rechit":
                            case "HE rechit":
                            case "EB rechit":
                            case "EE rechit":
                                infotext.text = item.title + "\n"
                                              + " energy = " + item.energy + "\n"
                                              + " eta = " + item.eta + "\n"
                                              + " phi = " + item.phi + "\n"
                                              + " time = " + item.time + "\n";
                                break;
                            case "Track":
                            case "Global muon":
                            case "Electron":
                                infotext.text = item.title + "\n"
                                              + " pt = " + item.pt + "\n"
                                              + " eta = " + item.eta + "\n"
                                              + " phi = " + item.phi + "\n"
                                              + " charge = " + item.charge + "\n";
                                break;
                            case "PF jet":
                                infotext.text = item.title + "\n"
                                              + " pt = " + item.pt + "\n"
                                              + " eta = " + item.eta + "\n"
                                              + " phi = " + item.phi + "\n"
                                              + " theta = " + item.theta + "\n";
                                break;
                            case "PF MET":
                                infotext.text = item.title + "\n"
                                              + " pt = " + item.pt + "\n"
                                              + " phi = " + item.phi + "\n";
                                break;
                            default:
                                break;
                        }
                        text.transform.localPosition = new Vector3 (0, 0f, 0.0f);
                        text.transform.localScale = new Vector3 (.00170f, .00219f, 1f);
						text.GetComponent<Text> ().font = Resources.GetBuiltinResource<Font> ("Arial.ttf");
                        text.GetComponent<Text>().fontStyle = FontStyle.Bold;
						text.GetComponent<Text>().color = Color.black;
						text.transform.parent = infocanvas.transform;
					}
				}
			}
			this_event.name = event_name;
			this_event.SetActive (false);
		    events[eventNumber] = this_event;	
			eventNumber++;
		}

		foreach(GameObject ev in events) {
			Debug.Log("found event " + ev.name); 
		}
		eventNumber = 0;
	}

	//Checks to determine what actions the player wants to happen
	public bool clicked() {
		if (OVRInput.GetUp (OVRInput.Button.SecondaryShoulder) || Input.GetKey(KeyCode.N)) {
			return true;
		} else {
			return false;
		}
	}

	public bool Unclick() {
		if (OVRInput.GetUp (OVRInput.RawButton.Y) || Input.GetKey(KeyCode.Y)) {
			return true;
		} else {
			return false;
		}
	}

	public bool backClick() {
		if (OVRInput.GetUp (OVRInput.Button.PrimaryShoulder) || Input.GetKey(KeyCode.B)) {
			return true;
		} else {
			return false;
		}
	}
	
    public void nextOne()
    {
        foreach (GameObject area in eventArea)
        {
            area.SetActive(false);
        }
        Destroy(this_event);
        if (eventNumber < events.Length - 1)
        {
            eventNumber++;
        }
        else {
            eventNumber = 0;
        }
        Debug.Log("loaded event is " + events[eventNumber].name);
        this_event = Instantiate(events[eventNumber]) as GameObject;
        this_event.SetActive(true);
    }

    public void lastOne()
    {
        foreach (GameObject area in eventArea)
        {
            area.SetActive(false);
        }
        Destroy(this_event);
        if (eventNumber == 0)
        {
            lastEvent = events.Count() - 1;
            eventNumber = lastEvent;
        }
        else
        {
            eventNumber--;
        }
        Debug.Log("loaded event is " + events[eventNumber].name);
        this_event = Instantiate(events[eventNumber]) as GameObject;
        this_event.SetActive(true);
    }

	void Update () {

		// moves one event forward in the array's list
		if (clicked()) {
            nextOne();
		}

		// moves one event back in the array's list
		if (backClick()) {
            lastOne();

        }

		// removes the events and replaces them with the detector pieces
		if (Unclick ()) {
			this_event.SetActive (false);

			foreach (GameObject area in eventArea) {
				area.SetActive (true);
			}
		}
	}
}
