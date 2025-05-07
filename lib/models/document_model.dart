class Document{
  String ? doc_title;
  String ? doc_url;
  String ? doc_date;
  int ? page_count;

  Document({this.doc_title, this.doc_url, this.doc_date, this.page_count});

  static List<Document> doc_list = [
    Document(
      doc_title: "The Great Gatsby",
      doc_url: "https://www.antennahouse.com/hubfs/xsl-fo-sample/pdf/basic-link-1.pdf",
      doc_date: "2019-12-12",
      page_count: 180
    ),
    Document(
      doc_title: "The Old one",
      doc_url:"https://morth.nic.in/sites/default/files/dd12-13_0.pdf",
      doc_date: "2020-04-25",
      page_count: 2
      ),
  ];  
}