#pragma once

class a_cpu_class {

 public:

  a_cpu_class() { ; }
  ~a_cpu_class() { ; }

  unsigned int get_member() const;
  void set_member(unsigned int val);

 private:
  unsigned int member = 0;

};
