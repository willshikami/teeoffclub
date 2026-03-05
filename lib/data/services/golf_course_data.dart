import 'package:teeoffclub/data/models/sports/golf_course.dart';

class GolfCourseData {
  static List<GolfCourse> getCourses() {
    return [
      GolfCourse(
        id: 'muthaiga-gc',
        name: 'Muthaiga Golf Club',
        location: 'Muthaiga, Nairobi',
        totalHoles: 18,
        difficulty: 'Championship',
        rating: 72.4,
        slope: 133,
        holes: _getHoles(pars: [4, 3, 4, 4, 4, 4, 5, 3, 4, 5, 3, 4, 3, 4, 4, 4, 4, 5]),
      ),
      GolfCourse(
        id: 'karen-cc',
        name: 'Karen Country Club',
        location: 'Karen, Nairobi',
        totalHoles: 18,
        difficulty: 'Parkland',
        rating: 71.8,
        slope: 130,
        holes: _getHoles(pars: [4, 4, 5, 4, 3, 4, 3, 5, 4, 4, 4, 5, 4, 3, 4, 3, 4, 5]),
      ),
      GolfCourse(
        id: 'windsor-gl',
        name: 'Windsor Golf & Country Club',
        location: 'Kigwa Lane, Nairobi',
        totalHoles: 18,
        difficulty: 'Indigenous Forest',
        rating: 74.1,
        slope: 141,
        holes: _getHoles(pars: [4, 4, 3, 5, 4, 4, 4, 3, 5, 4, 4, 5, 3, 4, 5, 4, 3, 4]),
      ),
      GolfCourse(
        id: 'sigona-gc',
        name: 'Sigona Golf Club',
        location: 'Kikuyu, Kiambu',
        totalHoles: 18,
        difficulty: 'Hilly Parkland',
        rating: 72.1,
        slope: 128,
        holes: _getHoles(pars: [4, 4, 4, 3, 5, 4, 4, 3, 5, 4, 3, 4, 5, 4, 4, 5, 3, 4]),
      ),
      GolfCourse(
        id: 'nyali-gc',
        name: 'Nyali Golf & Country Club',
        location: 'Mombasa',
        totalHoles: 18,
        difficulty: 'Coastal Links',
        rating: 70.2,
        slope: 125,
        holes: _getHoles(pars: [4, 4, 3, 5, 4, 4, 3, 4, 4, 4, 3, 4, 5, 4, 3, 4, 4, 5]),
      ),
      GolfCourse(
        id: 'limuru-cc',
        name: 'Limuru Country Club',
        location: 'Limuru, Kiambu',
        totalHoles: 18,
        difficulty: 'Highland',
        rating: 71.5,
        slope: 129,
        holes: _getHoles(pars: [4, 5, 4, 3, 4, 4, 3, 4, 5, 4, 3, 4, 5, 4, 4, 3, 4, 5]),
      ),
    ];
  }

  static List<HoleData> _getHoles({required List<int> pars}) {
    return List.generate(pars.length, (index) => HoleData(
      number: index + 1,
      par: pars[index],
    ));
  }
}
