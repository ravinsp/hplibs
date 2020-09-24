namespace HotPocket.Client
{
    public class ContractInputStatus
    {
        public bool Accepted { get; set; }
        public string Reason { get; set; }

        public ContractInputStatus(bool accepted, string reason = null)
        {
            Accepted = accepted;
            Reason = reason;
        }
    }
}