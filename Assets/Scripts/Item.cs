using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assets.Scripts
{
    public class Item
    {
        public string guid;
        public string dateTime;
        public string name;

        public Item() { }

        public Item(string guid, string dateTime, string name)
        {
            this.guid = guid;
            this.dateTime = dateTime;
            this.name = name;
        }
    }
}
