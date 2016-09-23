using UnityEngine;
using System.Collections;

public class MaterialAssigner : MonoBehaviour {


	private MeshRenderer [] cmsRender;
	private Material cmsColor;


	void Start () {
		cmsColor = Resources.Load ("cms_skpt", typeof(Material)) as Material;
		cmsRender = FindObjectsOfType (typeof(MeshRenderer)) as MeshRenderer[];
			//GetComponentInChildren<MeshRenderer> ();
		foreach (MeshRenderer mr in cmsRender) {
			mr.material = cmsColor;
		}
	}
	

	void Update () {

	}
}
