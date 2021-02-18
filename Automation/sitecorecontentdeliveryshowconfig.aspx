<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="Sitecore.Configuration" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Xml" %>

<script language="C#" runat="server">
    private const string API_KEY = "464799ae52214c80b7fc81408f8efbe0";

    public void Page_Load(object sender, EventArgs e)
    {
        if (Request.Headers["apikey"] == API_KEY) 
        {
            XmlDocument configuration = Factory.GetConfiguration();
            this.Response.ContentType = "text/xml";
            this.Response.Write(configuration.OuterXml);
            return;
        }
        throw new HttpException(401, "Authentication Failed");
    }
</script>
