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

using UnityEngine;
using System.Collections;

public class HomeBattery : MonoBehaviour
{
	public Gradient		batteryTempGradient = new Gradient();

	private Transform	juiceLevel = null;
	private Material	batteryMaterial = null;

	/// <summary>
	/// Initialization
	/// </summary>
	void Awake()
	{
		juiceLevel = transform.FindChild("juice");
		if (juiceLevel == null)
		{
			Debug.LogError("ERROR: battery juice child not found " + name);
			enabled = false;
			return;
		}
		// clone the battery material
		batteryMaterial = juiceLevel.GetComponent<Renderer>().material;
		OnRefresh();
	}

	/// <summary>
	/// Clean up cloned material
	/// </summary>	
	void OnDestroy()
	{
		if (batteryMaterial != null)
		{
			Destroy(batteryMaterial);
		}
	}

	/// <summary>
	/// Message handler that is called before the menu is redisplayed
	/// </summary>
	void OnRefresh()
	{
		Debug.Log("> Device Battery Level: " + OVRManager.batteryLevel);
		Vector3 scale = juiceLevel.localScale;
		scale.x = OVRManager.batteryLevel;
		juiceLevel.localScale = scale;

		Debug.Log("> Battery Temp: " + OVRManager.batteryTemperature + "C");
		// 30 degrees C == green/cool, 45 degrees C == red/hot
		float colorScale = Mathf.InverseLerp(30.0f, 45.0f, OVRManager.batteryTemperature);
		Color juiceColor = batteryTempGradient.Evaluate(colorScale);
		batteryMaterial.color = juiceColor;
	}
}
