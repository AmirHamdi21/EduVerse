import 'package:edu_verse/features/walkthrough/instructor_walkthrough_service.dart';
import 'package:edu_verse/features/walkthrough/role_walkthrough_cubit.dart';

typedef InstructorWalkthroughState = RoleWalkthroughState;

class InstructorWalkthroughCubit extends RoleWalkthroughCubit {
  InstructorWalkthroughCubit({required InstructorWalkthroughService service})
    : super(service: service);
}
