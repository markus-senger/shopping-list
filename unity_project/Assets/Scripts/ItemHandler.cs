using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class ItemHandler : MonoBehaviour
{
    [SerializeField] private TMP_Text nameText;
    [SerializeField] private TMP_Text dateTimeText;
    [SerializeField] private Button deleteButton;
    
    private DatabaseManager databaseManager;
    private string guid;


    private void Start()
    {
        deleteButton.onClick.AddListener(() =>
        {
            databaseManager.DeleteItem(guid);
        });
    }

    private void OnDestroy()
    {
        databaseManager.gameObject.GetComponent<UIHandler>().onDeleteActiveInstance -= EnableDeleteButton;
    }

    public void SetItemInfos(DatabaseManager databaseManager, string guid, string dateTime, string name)
    {
        this.databaseManager = databaseManager;
        this.guid = guid;
        dateTimeText.text = dateTime;
        nameText.text = name;

        databaseManager.gameObject.GetComponent<UIHandler>().onDeleteActiveInstance += EnableDeleteButton;
    }

    public void EnableDeleteButton(bool value)
    {
        deleteButton.interactable = value;
    }
}
