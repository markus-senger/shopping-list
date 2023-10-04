using Assets.Scripts;
using Firebase.Database;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class DatabaseManager : MonoBehaviour
{
    [SerializeField] private Button addItemButton;
    [SerializeField] private Button refreshButton;
    [SerializeField] private TMP_InputField itemInputField;
    [SerializeField] private GameObject contentPanel;
    [SerializeField] private GameObject itemPrefab;
    [SerializeField] private GameObject connectionErrorImage;

    private DatabaseReference reference;
    private bool getDataRunning;
    private bool isConnected;

    private void Start()
    {
        reference = FirebaseDatabase.DefaultInstance.RootReference;
        getDataRunning = false;

        DatabaseReference connectedRef = FirebaseDatabase.DefaultInstance.GetReference(".info/connected");
        connectedRef.ValueChanged += (object sender, ValueChangedEventArgs a) => {
            isConnected = (bool)a.Snapshot.Value;
            connectionErrorImage.SetActive(!isConnected);
            GetData();
        };

        GetData();

        addItemButton.onClick.AddListener(async () =>
        {
            if(itemInputField.text != "")
            {
                string guid = Guid.NewGuid().ToString();
                Item item = new Item(guid, DateTime.Now.ToString(), itemInputField.text);
                await reference.Child("items").Child(guid).SetRawJsonValueAsync(JsonUtility.ToJson(item));
                GetData();
                itemInputField.text = "";
                gameObject.GetComponent<UIHandler>().SetToggleValue(false);
            }
        });

        refreshButton.onClick.AddListener(() =>
        {
            GetData();
            gameObject.GetComponent<UIHandler>().SetToggleValue(false);
        });
    }

    private void GetData()
    {
        if(!getDataRunning && isConnected)
            StartCoroutine(GetItems());
    }

    private IEnumerator GetItems()
    {
        getDataRunning = true;

        foreach (Transform child in contentPanel.transform)
        {
            GameObject.Destroy(child.gameObject);
        }

        var itemdata = reference.Child("items").GetValueAsync();

        yield return new WaitUntil(predicate: () => itemdata.IsCompleted);

        if (itemdata != null && itemdata.Result != null)
        {
            List<Item> items = new List<Item>();
            DataSnapshot dataSnapshot = itemdata.Result;

            foreach (var itemSnapshot in dataSnapshot.Children)
            {
                string jsonData = itemSnapshot.GetRawJsonValue();
                Item item = JsonUtility.FromJson<Item>(jsonData);
                items.Add(item);
            }

            items = items.OrderByDescending(item => DateTime.Parse(item.dateTime)).ToList();

            foreach (var item in items)
            {
                GameObject itemObject = Instantiate(itemPrefab, contentPanel.transform);
                itemObject.GetComponent<ItemHandler>().SetItemInfos(this, item.guid, item.dateTime, item.name);
            }
        }

        gameObject.GetComponent<UIHandler>().SetToggleValue(keep: true);
        getDataRunning = false;
    }

    public async void DeleteItem(string guid)
    {
        await reference.Child("items").Child(guid).RemoveValueAsync();
        GetData();
    }
}
