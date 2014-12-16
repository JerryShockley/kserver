/////////////////////////////////////////////////////////////////////////
//                                                                     //
// Written and (C) by Jerome Berclaz                                   //
// email : berclaz@live.com                                            //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
#ifndef COMMON_H
#define COMMON_H

#include <string>

#ifdef __APPLE__
#include <TargetConditionals.h>
// Will define TARGET_OS_IPHONE to 1 if compiling for iOS, 0 if for Mac OS
#else	// __APPLE__
#define	TARGET_OS_IPHONE    0
#endif	// __APPLE__

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
