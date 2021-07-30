// abstract class TestApiApi extends RequestBuilderBase implements TestApi {
//   @override
//   HttpContent login({String? start, String? end, String? effect, String? bd}) {
//     var content = generator.generate('get/lol/pp', method: HttpMethod.post);
//     if (bd != null) {
//       content.addBody(
//         key: "bd",
//         value: "$bd",
//       );
//     }
//
//     if (start != null) {
//       content.addQueryParam("start", value: "$start");
//     }
//     if (end != null) {
//       content.addQueryParam("end", value: "$end");
//     }
//     if (effect != null) {
//       content.addQueryParam("effect", value: "$effect");
//     }
//     return content;
//   }
// }
