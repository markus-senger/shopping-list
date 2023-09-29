using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIHandler : MonoBehaviour
{
    [SerializeField] private Toggle enableDeleteToggle;

    public delegate void OnDeleteActive(bool value);
    public OnDeleteActive onDeleteActiveInstance;


    private void Start()
    {
        enableDeleteToggle.isOn = false;

        enableDeleteToggle.onValueChanged.AddListener((bool value) =>
        {
            onDeleteActiveInstance?.Invoke(value);
        });
    }

    public void SetToggleValue(bool value = false, bool keep = false)
    {
        if(!keep)
            enableDeleteToggle.isOn = value;

        enableDeleteToggle.onValueChanged.Invoke(enableDeleteToggle.isOn);
    }
}
