# 0.2.4

  * [ENHANCEMENT] support all the rack versions >= 1.5.2

# 0.2.3

  * [ENHANCEMENT] support all the rails versions >= 4.0.0

# 0.2.2

  * [BUGFIX] the tracker key got lost while merging multiple nested events into env

# 0.2.1

  * [BUGFIX] sending the ecommerce cart was misspelled

# 0.2.0

  * added support for GoSquared
  * added support for Visual Website Optimizer

# 0.1.3

  * [BUGFIX] ecommerce events weren't created properly

# 0.1.2

  * cart is now auto submitted to when ecommerce is turned on and items or transactions are in the queue

# 0.1.1

  * [BUGFIX] return value of the `tracker`-block is kinda unpredictabel, so we skip further processing

# 0.1.0

  * README
  * unified facebook and google handler `#track`-signature (3009b3834ad07caf8818484ddd86d8a0eb128fe5)

# 0.0.4

  * keep events over multiple redirectes
  * allow multiple calls of the same handler in one `tracker` block
