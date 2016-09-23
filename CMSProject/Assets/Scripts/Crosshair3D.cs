/************************************************************************************

Copyright   :   Copyright 2014 Oculus VR, LLC. All Rights reserved.

Licensed under the Oculus VR Rift SDK License Version 3.3 (the "License");
you may not use the Oculus VR Rift SDK except in compliance with the License,
which is provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

You may obtain a copy of the License at

http://www.oculus.com/licenses/LICENSE-3.3

Unless required by applicable law or agreed to in writing, the Oculus VR SDK
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

************************************************************************************/

// uncomment this to test the different modes.
#define CROSSHAIR_TESTING

using UnityEngine;
using System.Collections;				// required for Coroutines

public class Crosshair3D : MonoBehaviour
{

	// NOTE: three different crosshair methods are shown here.  The most comfortable for the
	// user is going to be when the crosshair is located in the world (or slightly in front of)
	// the position where the user's gaze is.  Positioning the cursor a fixed distance from the
	// camera inbetween the camera and the player's gaze will be uncomfortable and unfocused.
	public enum CrosshairMode
	{
		Dynamic = 0,			// cursor positions itself in 3D based on raycasts into the scene
		DynamicObjects = 1,		// similar to Dynamic but cursor is only visible for objects in a specific layer
		FixedDepth = 2,			// cursor positions itself based on camera forward and draws at a fixed depth
	}

	public CrosshairMode				mode = CrosshairMode.Dynamic;
	public int							objectLayer = 8;
	public float						offsetFromObjects = 0.1f;
	public float						fixedDepth = 3.0f;
	public OVRCameraRig					cameraController = null;

	private Transform					thisTransform = null;
	private Material					crosshairMaterial = null;

	/// <summary>
	/// Initialize the crosshair
	/// </summary>
	void Awake()
	{
		thisTransform = transform;
		if (cameraController == null)
		{
			Debug.LogError("ERROR: missing camera controller object on " + name);
			enabled = false;
			return;
		}
		// clone the crosshair material
		crosshairMaterial = GetComponent<Renderer>().material;
	}

	/// <summary>
	/// Cleans up the cloned material
	/// </summary>
	void OnDestroy()
	{
		if (crosshairMaterial != null)
		{
			Destroy(crosshairMaterial);
		}
	}

	/// <summary>
	/// Updates the position of the crosshair.
	/// </summary>
	void LateUpdate()
	{
#if CROSSHAIR_TESTING
		if (OVRInput.GetDown (OVRInput.RawButton.RShoulder))
		{
			//*************************
			// toggle the crosshair mode .. dynamic -> dynamic objects -> fixed depth
			//*************************
			switch(mode)
			{
			case CrosshairMode.Dynamic:
				mode = CrosshairMode.DynamicObjects;
				crosshairMaterial.color = Color.red;
				break;
			case CrosshairMode.DynamicObjects:
				mode = CrosshairMode.FixedDepth;
				crosshairMaterial.color = Color.blue;
				break;
			case CrosshairMode.FixedDepth:
				mode = CrosshairMode.Dynamic;
				crosshairMaterial.color = Color.white;
				break;
			}
			Debug.Log("Mode: " + mode);
		}
#endif
		Ray ray;
		RaycastHit hit;

		// get the camera forward vector and position
		Vector3 cameraPosition = cameraController.centerEyeAnchor.position;
		Vector3 cameraForward = cameraController.centerEyeAnchor.forward;

		GetComponent<Renderer>().enabled = true;

		//*************************
		// position the cursor based on the mode
		//*************************
		switch (mode)
		{
		case CrosshairMode.Dynamic:
			// cursor positions itself in 3D based on raycasts into the scene
			// trace to the spot that the player is looking at
			ray = new Ray(cameraPosition, cameraForward);
			if ( Physics.Raycast(ray, out hit))
			{
				thisTransform.position = hit.point + (-cameraForward * offsetFromObjects);
				thisTransform.forward = -cameraForward;
			}
			break;
		case CrosshairMode.DynamicObjects:
			// similar to Dynamic but cursor is only visible for objects in a specific layer
			ray = new Ray(cameraPosition, cameraForward);
			if (Physics.Raycast(ray, out hit))
			{
				if (hit.transform.gameObject.layer != objectLayer)
				{
					GetComponent<Renderer>().enabled = false;
				}
				else
				{
					thisTransform.position = hit.point + (-cameraForward * offsetFromObjects);
					thisTransform.forward = -cameraForward;
				}
			}
			break;
		case CrosshairMode.FixedDepth:
			// cursor positions itself based on camera forward and draws at a fixed depth
			thisTransform.position = cameraPosition + (cameraForward * fixedDepth);
			thisTransform.forward = -cameraForward;
			break;
		}

		if (OVRInput.GetDown(OVRInput.RawButton.A))
		{
			ray = new Ray(cameraPosition, cameraForward);
			if (Physics.Raycast(ray, out hit))
			{
				hit.transform.gameObject.BroadcastMessage("OnClick", SendMessageOptions.DontRequireReceiver);
			}
		}
	}
}
