using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TestHealthKit : MonoBehaviour {

	Text text;

	// Use this for initialization
	void Start () {
		HealthKit.Instance ().Initialize ();

		text = GetComponent<Text>();
	}
	
	// Update is called once per frame
	void Update () {
		text.text = HealthKit.Instance ().GetYesterdaysSteps ().ToString ();
	}
}
