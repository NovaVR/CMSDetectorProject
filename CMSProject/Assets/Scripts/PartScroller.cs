// Allows the player to remove and replace the parts of the detector
// Created by Oliver Lykken

using UnityEngine;
using System.Collections;

public class PartScroller : MonoBehaviour {

	public GameObject[] cmsParts;
	int i = 0;

	void Update () {
		if (Input.GetButtonDown ("X")) {
			cmsParts [i].SetActive (false);
			i++;
			if (i > cmsParts.Length - 1) {
				i = 0;
			}
		}

		if (Input.GetButtonDown ("B")) {
			cmsParts [i].SetActive (true);
			i++;
			if (i > cmsParts.Length - 1) {
				i = 0;
			}
		}
	}
}
