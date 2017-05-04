using UnityEngine;
using System;
using System.Collections;
using System.Runtime.InteropServices;

public class HealthKit {
	[DllImport ("__Internal")]
	private static extern int _GetYesterdaysSteps ();

	[DllImport ("__Internal")]
	private static extern void _Initialize ();

	private static readonly HealthKit _singleton = new HealthKit();

	private HealthKit() {}

	public static HealthKit Instance() {
		return _singleton;
	}

	public void Initialize() {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			_Initialize ();
		}
	}

	public int  GetYesterdaysSteps() {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			return _GetYesterdaysSteps ();
		}
		return -1;
	}
}
