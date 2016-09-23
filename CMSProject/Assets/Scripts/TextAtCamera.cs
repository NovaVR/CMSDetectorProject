// Forces infoCanvases to always face the player
//Created by Oliver Lykken

using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class TextAtCamera : MonoBehaviour {

	public GameObject[] infoCanvases;
	public Transform camera;

	//Get the players camera
	void Start () {
		camera = Camera.main.transform;
	}


	void Update () {
		infoCanvases = GameObject.FindGameObjectsWithTag("InfoCanvas");
		foreach (GameObject infoCanvas in infoCanvases) {
			infoCanvas.transform.LookAt (camera.position);
			infoCanvas.transform.Rotate (0.0f, 180.0f, 0.0f);
		}
	}
}
