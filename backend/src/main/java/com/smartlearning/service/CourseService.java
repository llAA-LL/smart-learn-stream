package com.smartlearning.service;

import com.smartlearning.entity.Course;
import com.smartlearning.dto.PagedResult;
import com.smartlearning.exception.BusinessException;
import com.smartlearning.mapper.CourseMapper;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class CourseService {

    private final CourseMapper courseMapper;
    private final CacheService cacheService;

    public CourseService(CourseMapper courseMapper, CacheService cacheService) {
        this.courseMapper = courseMapper;
        this.cacheService = cacheService;
    }

    public List<Course> findAll() {
        return cacheService.getOrLoadCourseList(courseMapper::findAll);
    }

    public PagedResult<Course> page(int page, int pageSize) {
        List<Course> list = courseMapper.findPage((page - 1) * pageSize, pageSize);
        return new PagedResult<>(list, courseMapper.countAll(), page, pageSize);
    }

    public Course findById(Long id) {
        Course course = courseMapper.findById(id);
        if (course == null) {
            throw new BusinessException(404, "课程不存在");
        }
        return course;
    }

    public Course create(Course course) {
        courseMapper.insert(course);
        cacheService.evictCourseCache();
        return course;
    }

    public Course update(Course course) {
        Course exist = findById(course.getId());
        courseMapper.update(course);
        cacheService.evictCourseCache();
        return course;
    }

    public void delete(Long id) {
        findById(id);
        courseMapper.delete(id);
        cacheService.evictCourseCache();
    }
}
