
// Created by Oliver Lykken
// This script allows the informational text to be desplayed when a player looks at part of the detector.

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using System.Collections;
using System.Collections.Generic;

public class CrosshairRaycast : MonoBehaviour {

	Ray ray;
	RaycastHit hit;
	public OVRCameraRig ocamera;
	Transform ctransform;
	private bool isInfo = false;
	//private Vector3 startRotation;
	private GameObject target;
	private GameObject lastInfo;
	private int arrayIndex = 0;
	private string currentTag;
	public List <GameObject> _allInfos = new List<GameObject>();
	public GameObject info;

	public float flipTime = 2.0f;
	private float countDown;

	// Use this for initialization
	void Start () {
		countDown = flipTime;
	}

	// Update is called once per frame
	void Update () {
//		Vector3 forward = transform.TransformDirection (Vector3.forward);
		Vector3 cameraPosition = ocamera.centerEyeAnchor.position;
		Vector3 cameraForward = ocamera.centerEyeAnchor.forward;

//		target = new GameObject ();
		ray = new Ray(cameraPosition, cameraForward);
		Debug.DrawRay (cameraPosition, cameraForward, Color.blue, 3);
//		if (Physics.Raycast(ray, out hit)) {
		if (Physics.Raycast (cameraPosition, cameraForward, out hit, 5.0f)) {
			target = hit.collider.gameObject;
			info = target.transform.Find("InfoCanvas").gameObject;
			_allInfos.Add (info);
			arrayIndex++;
			lastInfo = _allInfos[arrayIndex-1];
			if (info != null) {
				//startRotation = info.transform.eulerAngles;
				ShowInfo ();
				countDown = flipTime;
				Debug.Log ("Found an object with tag " + target.tag + " at distance: " + hit.distance);
			}
		} 
		if ((hit.collider == null || target.tag != currentTag) && isInfo) {
			//countDown -= Time.deltaTime;
			//if (countDown <= 0.0f) {
			Debug.Log ("Found new target tag " + target.tag + " replacing current tag " + currentTag);
				HideInfo ();
			//} 
		}

	}

	private void HideInfo() {
			isInfo = false;
		info.GetComponent<Canvas> ().enabled = false;
		info.SetActive (false);
			lastInfo.GetComponent<Canvas>().enabled = false;
			lastInfo.SetActive (false);
	}

	private void ShowInfo () {
			isInfo = true;
			info.GetComponent<Canvas>().enabled = true;
			info.SetActive (true);
			currentTag = target.tag;
	}
}
