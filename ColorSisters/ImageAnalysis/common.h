/////////////////////////////////////////////////////////////////////////
//                                                                     //
// Written and (C) by Jerome Berclaz                                   //
// email : berclaz@live.com                                            //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
#ifndef COMMON_H
#define COMMON_H

#include <string>

class KokkoException
{
 private:
  std::string message;

 public:
 KokkoException(const char *message): message(message)
  {
  }

 KokkoException(const std::string &message): message(message)
  {
  }
  
  const std::string &get_message() const { return message; }
  
};

#endif
