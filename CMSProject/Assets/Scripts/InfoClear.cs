using UnityEngine;
using System.Collections;

public class InfoClear : MonoBehaviour {

    private Valve.VR.EVRButtonId gripButton = Valve.VR.EVRButtonId.k_EButton_Grip;
    private SteamVR_Controller.Device controller { get { return SteamVR_Controller.Input((int)trackedObj.index); } }
    private SteamVR_TrackedObject trackedObj;

    private GameObject child;
    private GameObject lastTarget;

    // Use this for initialization
    void Start () {
        trackedObj = GetComponent<SteamVR_TrackedObject>();
    }
	
	// Update is called once per frame
	void Update () {
        if (controller.GetPressUp(gripButton))
        {
            for (int i = 2; i < gameObject.transform.childCount; i++)
            {
                child = gameObject.transform.GetChild(i).gameObject;
                child.transform.parent = lastTarget.transform;
                child.transform.position = new Vector3(0, 0, 0);
            }
        }
	}

    private void OnTriggerEnter (Collider collider)
    {
        lastTarget = collider.gameObject;
    }
    private void OnTriggerExit (Collider collider)
    {
        lastTarget = collider.gameObject;
    }
}
