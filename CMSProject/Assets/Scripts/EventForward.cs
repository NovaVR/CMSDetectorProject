using UnityEngine;
using System.Collections;

public class EventForward : MonoBehaviour {

    public GameObject escroll;

    private Valve.VR.EVRButtonId triggerButton = Valve.VR.EVRButtonId.k_EButton_SteamVR_Trigger;

    private SteamVR_TrackedObject trackedObject;
    private SteamVR_Controller.Device controller { get { return SteamVR_Controller.Input((int)trackedObject.index); } }

    // Get trigger inputs
    void Start()
    {
        trackedObject = GetComponent<SteamVR_TrackedObject>();
        //escroll = GameObject.Find("cms_120528_01").GetComponent<EventScroller>();
    }

    // Update is called once per frame
    void Update()
    {
        if (controller.GetPressDown(triggerButton))
        {
            controller.TriggerHapticPulse(5000);
            escroll.GetComponent<EventScroller>().nextOne();
            Debug.Log("right trigger was pressed");
        }
    }
}
