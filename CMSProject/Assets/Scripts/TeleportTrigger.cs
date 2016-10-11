using UnityEngine;
using System.Collections;

public class TeleportTrigger : MonoBehaviour {

    private Valve.VR.EVRButtonId gripButton = Valve.VR.EVRButtonId.k_EButton_Grip;
    private SteamVR_Controller.Device controller { get { return SteamVR_Controller.Input((int)trackedObj.index); } }
    private SteamVR_TrackedObject trackedObj;

    public GameObject rig;

    // Use this for initialization
    void Start () {
        trackedObj = GetComponent<SteamVR_TrackedObject>();
    }

    private void OnTriggerEnter(Collider collider)
    {
        if (collider.gameObject.CompareTag("ControlRoom"))
        {
            ToControlRoom();
        }
        else if (collider.gameObject.CompareTag("Surface"))
        {
            TeleportUp();
        }
        else if (collider.gameObject.CompareTag("DetectorRoom"))
        {
            TeleportDown();
        }
    }

    public void TeleportUp()
    {
        rig.transform.position = new Vector3(87.04f, 2f, 108.7f);
    }

    public void TeleportDown()
    {
        rig.transform.position = new Vector3(5.36f, -119f, -3.87f);
    }

    public void ToControlRoom()
    {
        rig.transform.position = new Vector3(68.223f, 1.915f, -.07f);
    }
}
