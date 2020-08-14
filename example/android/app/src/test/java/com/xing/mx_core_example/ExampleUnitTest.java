package com.xing.mx_core_example;

import org.junit.Test;

public class ExampleUnitTest {

    @Test
    public void testAA() {
        System.out.println("打印測試");

        TestAA a = new TestBB();
        TestBB b = new TestBB();

        TestBB c = (TestBB) a;

        System.out.println("打印 a = " + a.x + ", b = " + b.x + ", c = " + c.x);
    }
}

class TestAA {
    int x = 1;
}

class TestBB extends TestAA {
    int x = 2;
}
