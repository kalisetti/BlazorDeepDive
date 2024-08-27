﻿namespace ServerManagement.StateStore
{
    public class MontrealOnlineServersStore : Observer
    {
        private int _numServersOnline;

        public int GetNumberServersOnline()
        {
            return _numServersOnline;
        }

        public void SetNumbersServersOnline(int number)
        {
            _numServersOnline = number;
            base.BroadcastStateChange();
        }

    }
}
