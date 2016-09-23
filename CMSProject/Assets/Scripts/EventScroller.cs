//This script allows the player to scroll between the different events for the detector
//Created by Oliver Lykken

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Serialization;
using UnityEngine.UI;

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

		//events = Resources.LoadAll("events", typeof(GameObject))
			//.Cast<GameObject>()
			//.ToArray();

		//jsons = Resources.LoadAll ("JSON");

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
			//this_event.transform.localScale = new Vector3 (0.01f, 0.01f, 0.01f); 
			ItemContainer ic = new ItemContainer ();
			ic = ItemContainer.Load(xml_path);
			event_collection = Resources.LoadAll(event_path, typeof(GameObject))
				.Cast<GameObject>()
				.ToArray();

			//Createst the parts of the events that the data is attached to
			foreach (GameObject sub_event in event_collection) {
				GameObject this_sub_event = Instantiate (sub_event) as GameObject;
				//this_sub_event.SetActive (false);
				this_sub_event.transform.position = new Vector3 (0, -119.9f, 0);
				this_sub_event.transform.localScale = new Vector3 (50f, 50f, 50f);
				this_sub_event.transform.parent = this_event.transform;
				this_sub_event.tag = "Track";
				Mesh m = this_sub_event.GetComponentInChildren<MeshFilter> ().sharedMesh;
				this_sub_event.AddComponent<MeshCollider> ();
				this_sub_event.GetComponent<MeshCollider> ().sharedMesh = m;
				this_sub_event.GetComponent<MeshCollider> ().convex = true;
				this_sub_event.GetComponent<MeshCollider> ().isTrigger = true;
				//GameObject mesh1 = this_sub_event.transform.Find ("Mesh1").gameObject;
				//this_sub_event.GetComponent<MeshCollider> ().sharedMesh = mesh1.GetComponent<Mesh>();
				//Debug.Log ("this_sub_event_name = " + this_sub_event.name);

				//Creates the canvases where the data for each sub part of the event will be attached
				foreach(Item item in ic.items) {
					if (this_sub_event.name.Contains(item.name +"(Clone)")) {
						GameObject infocanvas = new GameObject ("InfoCanvas");
						infocanvas.AddComponent<Canvas> ();
						infocanvas.AddComponent<GraphicRaycaster> ();
						infocanvas.AddComponent<CanvasScaler> ();
						infocanvas.tag = "InfoCanvas";
						infocanvas.transform.position = new Vector3 (0, -119f, 0);
						infocanvas.transform.localScale = new Vector3 (0.02f, 0.02f, 0.02f);
						infocanvas.transform.parent = this_sub_event.transform;
						infocanvas.SetActive (false);
						GameObject text = new GameObject ("Text");
						Text infotext = text.AddComponent<Text> ();
						infotext.text = " pt = " + item.pt + "\n"
						+ " eta = " + item.eta + "\n"
						+ " phi = " + item.phi + "\n"
						+ " charge = " + item.charge + "\n";
						text.transform.localPosition = new Vector3 (0, -119f, 0.0f);
						text.transform.localScale = new Vector3 (0.02f, 0.02f, 0.02f);
						text.GetComponent<Text> ().font = Resources.GetBuiltinResource<Font> ("Arial.ttf");
						text.GetComponent<Text>().color = Color.red;
						text.transform.parent = infocanvas.transform;
						/*GameObject image = new GameObject ("Image");
						image.AddComponent<Image> ();
						image.transform.localPosition = new Vector3 (0, -119f, 0.5f);
						image.transform.localScale = new Vector3 (0.02f, 0.02f, 0.02f);
						image.transform.parent = infocanvas.transform;
						Material mat;
						mat = Resources.Load ("Materials/metal pattern 32") as Material;
						image.GetComponent<Image> ().material = mat;*/
					}
				}
			}
			this_event.name = event_name;
			this_event.SetActive (false);
		    events[eventNumber] = this_event;	
			eventNumber++;
		}

		//for (int i = 0; i < events.Length; i++) {
			//events[i].name = i.ToString ();
		//}
		foreach(GameObject ev in events) {
			Debug.Log("found event " + ev.name); 
		}
		//Debug.Log ("loaded event is " + events [eventNumber].name);
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
	

	void Update () {

		// moves one event forward in the array's list
		if (clicked()) {
			foreach(GameObject area in eventArea) {
				area.SetActive (false);	
			}
			Destroy (this_event);
			if (eventNumber < events.Length - 1) {
				eventNumber++;
			} else {
				eventNumber = 0;
			}
			Debug.Log ("loaded event is " + events [eventNumber].name);
			this_event = Instantiate (events [eventNumber]) as GameObject;
			this_event.SetActive (true);
		}

		// moves one event back in the array's list
		if (backClick()) {
			foreach(GameObject area in eventArea) {
				area.SetActive (false);	
			}
			Destroy (this_event);
			if (eventNumber == 0) {
				lastEvent = events.Count() - 1;
				eventNumber = lastEvent;
			}else {
				eventNumber--;
			}
			Debug.Log ("loaded event is " + events [eventNumber].name);
			this_event = Instantiate (events [eventNumber]) as GameObject;
			this_event.SetActive (true);
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
