using UnityEngine;
using System.Collections;

public class InfoGrab : MonoBehaviour {

    private Valve.VR.EVRButtonId gripButton = Valve.VR.EVRButtonId.k_EButton_Grip;
    private SteamVR_Controller.Device controller { get { return SteamVR_Controller.Input((int)trackedObj.index); } }
    private SteamVR_TrackedObject trackedObj;

    private GameObject target;
    private GameObject info;


	// Use this for initialization
	void Start () {
        trackedObj = GetComponent<SteamVR_TrackedObject>();
	}
	
	// Update is called once per frame
	void Update () {
        if(controller.GetPressDown(gripButton) && info != null)
        {
            info.transform.position = this.transform.position;
            info.transform.parent = this.transform;
        }
        if (controller.GetPressUp(gripButton) && info != null)
        {
            info.transform.parent = target.transform;
            info.transform.position = target.transform.position;
        }
    }

    private void OnTriggerEnter(Collider collider)
    {
        target = collider.gameObject;
        info = target.transform.FindChild("InfoCanvas").gameObject;
    }

    private void OnTriggerExit(Collider collider)
    {
        target = null;
        info = null;
    }
}
